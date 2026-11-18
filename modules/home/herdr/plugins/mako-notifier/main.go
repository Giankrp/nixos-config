package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

// Config represents mako-notifier configuration
type Config struct {
	IgnoreIfFocused bool
	SoundEnabled    bool
	SoundBlocked    string
	SoundDone       string

	BlockedUrgency string
	BlockedTitle   string
	BlockedBody    string
	BlockedIcon    string

	DoneUrgency string
	DoneTitle   string
	DoneBody    string
	DoneIcon    string
}

func loadConfig(configDir string) Config {
	cfg := Config{
		IgnoreIfFocused: true,
		SoundEnabled:    false,
		SoundBlocked:    "",
		SoundDone:       "",

		BlockedUrgency: "critical",
		BlockedTitle:   "⏳ {agent} necesita tu confirmación",
		BlockedBody:    "En [{workspace} > {tab}] · {title}",
		BlockedIcon:    "dialog-warning",

		DoneUrgency: "normal",
		DoneTitle:   "✅ {agent} completó la tarea",
		DoneBody:    "En [{workspace} > {tab}] · {title}",
		DoneIcon:    "dialog-information",
	}

	searchDirs := []string{
		configDir,
		os.Getenv("HERDR_PLUGIN_CONFIG_DIR"),
		os.Getenv("HERDR_PLUGIN_ROOT"),
		"/etc/nixos/modules/home/herdr/plugins/mako-notifier",
	}

	var data []byte
	for _, dir := range searchDirs {
		if dir == "" {
			continue
		}
		path := filepath.Join(dir, "config.toml")
		if d, err := os.ReadFile(path); err == nil {
			data = d
			break
		}
	}

	if len(data) == 0 {
		return cfg
	}

	lines := strings.Split(string(data), "\n")
	var section string
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "#") || line == "" {
			continue
		}
		if strings.HasPrefix(line, "[") && strings.HasSuffix(line, "]") {
			section = strings.Trim(line, "[]")
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}
		key := strings.TrimSpace(parts[0])
		val := strings.TrimSpace(parts[1])
		val = strings.Trim(val, "\"")

		switch section {
		case "general":
			switch key {
			case "ignore_if_focused":
				cfg.IgnoreIfFocused = val == "true"
			case "sound_enabled":
				cfg.SoundEnabled = val == "true"
			case "sound_blocked":
				cfg.SoundBlocked = val
			case "sound_done":
				cfg.SoundDone = val
			}
		case "blocked":
			switch key {
			case "urgency":
				cfg.BlockedUrgency = val
			case "title":
				cfg.BlockedTitle = val
			case "body":
				cfg.BlockedBody = val
			case "icon":
				cfg.BlockedIcon = val
			}
		case "done":
			switch key {
			case "urgency":
				cfg.DoneUrgency = val
			case "title":
				cfg.DoneTitle = val
			case "body":
				cfg.DoneBody = val
			case "icon":
				cfg.DoneIcon = val
			}
		}
	}

	return cfg
}

type EventPayload struct {
	Type string                 `json:"type"`
	Data map[string]interface{} `json:"data"`
}

type ContextPayload struct {
	WorkspaceID    string `json:"workspace_id"`
	WorkspaceLabel string `json:"workspace_label"`
	TabID          string `json:"tab_id"`
	TabLabel       string `json:"tab_label"`
	PaneID         string `json:"pane_id"`
	FocusedPaneID  string `json:"focused_pane_id"`
	Focused        bool   `json:"focused"`
	Agent          string `json:"agent"`
	AgentStatus    string `json:"agent_status"`
	Status         string `json:"status"`
}

type AgentInfo struct {
	Agent       string `json:"agent"`
	AgentStatus string `json:"agent_status"`
	Title       string `json:"terminal_title_stripped"`
	WorkspaceID string `json:"workspace_id"`
	TabID       string `json:"tab_id"`
	PaneID      string `json:"pane_id"`
	Focused     bool   `json:"focused"`
}

func sendNotification(urgency, icon, title, body, soundFile string, cfg Config) {
	args := []string{"-a", "Herdr", "-u", urgency}
	if icon != "" {
		args = append(args, "-i", icon)
	}
	args = append(args, title, body)
	_ = exec.Command("notify-send", args...).Run()

	if cfg.SoundEnabled && soundFile != "" {
		if _, err := exec.LookPath("pw-play"); err == nil {
			_ = exec.Command("pw-play", soundFile).Start()
		} else if _, err := exec.LookPath("paplay"); err == nil {
			_ = exec.Command("paplay", soundFile).Start()
		}
	}
}

func formatText(tmpl string, repl map[string]string) string {
	res := tmpl
	for k, v := range repl {
		res = strings.ReplaceAll(res, "{"+k+"}", v)
	}
	return res
}

func handleEvent(cfg Config) {
	eventRaw := os.Getenv("HERDR_PLUGIN_EVENT_JSON")
	ctxRaw := os.Getenv("HERDR_PLUGIN_CONTEXT_JSON")

	var event EventPayload
	_ = json.Unmarshal([]byte(eventRaw), &event)

	var ctx ContextPayload
	_ = json.Unmarshal([]byte(ctxRaw), &ctx)

	data := event.Data
	if data == nil {
		data = make(map[string]interface{})
	}

	getString := func(key string, fallback string) string {
		if v, ok := data[key]; ok {
			if s, ok := v.(string); ok && s != "" {
				return s
			}
		}
		return fallback
	}

	status := strings.ToLower(getString("agent_status", ctx.AgentStatus))
	if status == "" {
		status = strings.ToLower(getString("status", ctx.Status))
	}

	if status != "blocked" && status != "done" {
		return
	}

	paneID := getString("pane_id", ctx.PaneID)
	if paneID == "" {
		paneID = ctx.FocusedPaneID
	}

	// Focus check
	if cfg.IgnoreIfFocused {
		isFocused := false
		if f, ok := data["focused"].(bool); ok && f {
			isFocused = true
		} else if ctx.Focused || (ctx.FocusedPaneID != "" && ctx.FocusedPaneID == paneID) {
			isFocused = true
		} else {
			// Query herdr api snapshot to see if pane is focused
			herdrBin := os.Getenv("HERDR_BIN_PATH")
			if herdrBin == "" {
				herdrBin = "herdr"
			}
			out, err := exec.Command(herdrBin, "api", "snapshot").Output()
			if err == nil {
				var snap struct {
					Result struct {
						Snapshot struct {
							FocusedPaneID string `json:"focused_pane_id"`
						} `json:"snapshot"`
					} `json:"result"`
				}
				if json.Unmarshal(out, &snap) == nil {
					if snap.Result.Snapshot.FocusedPaneID == paneID {
						isFocused = true
					}
				}
			}
		}

		if isFocused {
			return
		}
	}

	// Deduplication via state file
	stateDir := os.Getenv("HERDR_PLUGIN_STATE_DIR")
	if stateDir == "" {
		stateDir = os.TempDir()
	}
	stateFile := filepath.Join(stateDir, "mako-notifier-state.json")
	stateMap := make(map[string]string)
	if sfData, err := os.ReadFile(stateFile); err == nil {
		_ = json.Unmarshal(sfData, &stateMap)
	}

	lastStatus := stateMap[paneID]
	if lastStatus == status {
		// Ya fue notificado este estado para este pane
		return
	}
	stateMap[paneID] = status
	if sfBytes, err := json.Marshal(stateMap); err == nil {
		_ = os.WriteFile(stateFile, sfBytes, 0644)
	}

	agent := getString("display_agent", getString("agent", ctx.Agent))
	if agent == "" {
		agent = "Agent"
	}
	agent = strings.ToUpper(agent[:1]) + agent[1:]

	ws := getString("workspace_label", ctx.WorkspaceLabel)
	if ws == "" {
		ws = getString("workspace_id", ctx.WorkspaceID)
	}
	if ws == "" {
		ws = "Workspace"
	}

	tab := getString("tab_label", ctx.TabLabel)
	if tab == "" {
		tab = getString("tab_id", ctx.TabID)
	}
	if tab == "" {
		tab = "Tab"
	}

	title := getString("terminal_title_stripped", getString("title", ""))

	repl := map[string]string{
		"agent":     agent,
		"status":    status,
		"workspace": ws,
		"tab":       tab,
		"title":     title,
		"pane":      paneID,
	}

	if status == "blocked" {
		t := formatText(cfg.BlockedTitle, repl)
		b := formatText(cfg.BlockedBody, repl)
		sendNotification(cfg.BlockedUrgency, cfg.BlockedIcon, t, b, cfg.SoundBlocked, cfg)
	} else if status == "done" {
		t := formatText(cfg.DoneTitle, repl)
		b := formatText(cfg.DoneBody, repl)
		sendNotification(cfg.DoneUrgency, cfg.DoneIcon, t, b, cfg.SoundDone, cfg)
	}
}

func runDaemon(cfg Config) {
	sockPath := os.Getenv("HERDR_SOCKET_PATH")
	if sockPath == "" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			homeDir = "/home/gian"
		}
		sockPath = filepath.Join(homeDir, ".config/herdr/herdr.sock")
	}

	type SocketResp struct {
		Result struct {
			Agents []AgentInfo `json:"agents"`
		} `json:"result"`
	}

	stateMap := make(map[string]string)

	for {
		conn, err := net.Dial("unix", sockPath)
		if err != nil {
			time.Sleep(2 * time.Second)
			continue
		}

		reader := bufio.NewReader(conn)
		for {
			req := `{"id":"poll","method":"agent.list","params":{}}` + "\n"
			if _, err := conn.Write([]byte(req)); err != nil {
				break
			}

			line, err := reader.ReadBytes('\n')
			if err != nil {
				break
			}

			var resp SocketResp
			if err := json.Unmarshal(line, &resp); err == nil {
				for _, a := range resp.Result.Agents {
					lastStatus, exists := stateMap[a.PaneID]
					if exists && lastStatus != a.AgentStatus {
						repl := map[string]string{
							"agent":     strings.Title(a.Agent),
							"status":    a.AgentStatus,
							"workspace": a.WorkspaceID,
							"tab":       a.TabID,
							"title":     a.Title,
							"pane":      a.PaneID,
						}
						if a.AgentStatus == "blocked" {
							if !(cfg.IgnoreIfFocused && a.Focused) {
								t := formatText(cfg.BlockedTitle, repl)
								b := formatText(cfg.BlockedBody, repl)
								sendNotification(cfg.BlockedUrgency, cfg.BlockedIcon, t, b, cfg.SoundBlocked, cfg)
							}
						} else if a.AgentStatus == "done" && (lastStatus == "working" || lastStatus == "blocked") {
							if !(cfg.IgnoreIfFocused && a.Focused) {
								t := formatText(cfg.DoneTitle, repl)
								b := formatText(cfg.DoneBody, repl)
								sendNotification(cfg.DoneUrgency, cfg.DoneIcon, t, b, cfg.SoundDone, cfg)
							}
						}
					}
					stateMap[a.PaneID] = a.AgentStatus
				}
			}

			time.Sleep(800 * time.Millisecond)
		}
		_ = conn.Close()
		time.Sleep(2 * time.Second)
	}
}

func main() {
	testFlag := flag.Bool("test", false, "Send test notification")
	daemonFlag := flag.Bool("daemon", false, "Run in background polling loop")
	flag.Parse()

	exePath, err := os.Executable()
	var baseDir string
	if err == nil {
		baseDir = filepath.Dir(exePath)
	} else {
		baseDir = "."
	}
	if filepath.Base(baseDir) == "bin" {
		baseDir = filepath.Dir(baseDir)
	}

	cfg := loadConfig(baseDir)

	if *testFlag || os.Getenv("HERDR_PLUGIN_ACTION_ID") == "test" {
		sendNotification(
			"normal",
			"dialog-information",
			"🔔 Herdr Notifier: Prueba",
			"Las notificaciones de Mako están configuradas y listas para usar.",
			cfg.SoundDone,
			cfg,
		)
		fmt.Println("Notificación de prueba enviada.")
		return
	}

	// Si fue invocado por un evento de Herdr:
	if os.Getenv("HERDR_PLUGIN_EVENT_JSON") != "" {
		handleEvent(cfg)
		return
	}

	// Si se pide modo daemon o si no hay evento y tampoco es test:
	if *daemonFlag || os.Getenv("HERDR_PLUGIN_EVENT") == "startup" {
		runDaemon(cfg)
		return
	}

	// Por defecto si se corre sin flags y sin eventos:
	runDaemon(cfg)
}
