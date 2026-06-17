import { App, Astal, Gtk } from "astal/gtk3";
import { Variable, bind, execAsync, exec } from "astal";
import AstalApps from "gi://AstalApps";

const time = Variable("").poll(1000, ["date", "+%a %b %d, %H:%M"]);
const volumeRaw = Variable("").poll(1000, ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]);
const volumeValue = Variable(0).poll(1000, ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}' 2>/dev/null || echo '0'"]);
const batteryRaw = Variable("").poll(5000, ["sh", "-c", "echo \"$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0) $(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown)\""]);
const wifiRaw = Variable("").poll(5000, ["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || true"]);
const cpuRaw = Variable("").poll(2000, ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"]);
const ramRaw = Variable("").poll(2000, ["sh", "-c", "free -m | awk '/Mem:/ {printf \"%d\", $3/$2*100}'"]);
const niriStateRaw = Variable('{"workspaces":[],"windows":[]}').poll(500, ["sh", "-c", "echo \"{ \\\"workspaces\\\": $(niri msg -j workspaces 2>/dev/null || echo '[]'), \\\"windows\\\": $(niri msg -j windows 2>/dev/null || echo '[]') }\""]);
const mprisRaw = Variable("Stopped||").poll(2000, ["sh", "-c", "echo \"$(playerctl status 2>/dev/null || echo Stopped)|$(playerctl metadata title 2>/dev/null || echo)|$(playerctl metadata artist 2>/dev/null || echo)\""]);

const getAppIcon = (appId) => {
    if (!appId) return "󰖲";
    const id = appId.toLowerCase();
    if (id.includes("firefox")) return "󰈹";
    if (id.includes("chrome") || id.includes("chromium")) return "󰊯";
    if (id.includes("kitty") || id.includes("alacritty") || id.includes("terminal") || id.includes("wezterm")) return "";
    if (id.includes("code") || id.includes("visual-studio")) return "󰨞";
    if (id.includes("nvim") || id.includes("neovim")) return "";
    if (id.includes("discord") || id.includes("vesktop")) return "󰙯";
    if (id.includes("spotify")) return "󰓇";
    if (id.includes("steam")) return "󰓓";
    if (id.includes("nautilus") || id.includes("thunar") || id.includes("dolphin") || id.includes("yazi")) return "󰉋";
    if (id.includes("slack")) return "󰒱";
    if (id.includes("telegram")) return "󰔗";
    if (id.includes("thunderbird")) return "󰻧";
    return "󰖲";
};

function Workspaces() {
    return (
        <box className="workspaces">
            {bind(niriStateRaw).as(raw => {
                try {
                    const state = JSON.parse(raw);
                    const workspaces = state.workspaces || [];
                    const windows = state.windows || [];
                    
                    if (!Array.isArray(workspaces) || workspaces.length === 0) {
                        return [<label label="•" />];
                    }
                    
                    workspaces.sort((a, b) => a.idx - b.idx);
                    
                    return workspaces.map(ws => {
                        const wsWindows = windows.filter(w => w.workspace_id === ws.id);
                        
                        let className = "workspace-pill";
                        if (ws.is_focused) className += " focused";
                        else if (wsWindows.length > 0) className += " active";
                        else className += " empty";
                        
                        const icons = wsWindows.map(w => getAppIcon(w.app_id));
                        const uniqueIcons = [...new Set(icons)];
                        
                        return (
                            <button
                                className={className}
                                onClicked={() => {
                                    execAsync(`niri msg action focus-workspace ` + ws.idx);
                                }}
                            >
                                <box className="workspace-content">
                                    <label className="workspace-index" label={ws.idx.toString()} />
                                    {uniqueIcons.length > 0 && (
                                        <box className="workspace-icons">
                                            {uniqueIcons.map(icon => (
                                                <label className="workspace-icon" label={` ` + icon} />
                                            ))}
                                        </box>
                                    )}
                                </box>
                            </button>
                        );
                    });
                } catch (e) {
                    return [<label label="•" />];
                }
            })}
        </box>
    );
}

function MprisModule() {
    return (
        <box className="mpris-container">
            {bind(mprisRaw).as(raw => {
                if (!raw) return <box />;
                const parts = raw.split("|");
                const status = parts[0];
                const title = parts[1] || "";
                const artist = parts[2] || "";
                
                if (status === "Stopped" || !title) return <box visible={false} />;
                
                let displayTitle = title;
                if (title.length > 22) {
                    displayTitle = title.substring(0, 19) + "...";
                }
                
                return (
                    <box className="module mpris-module">
                        <label className="mpris-icon" label="󰎆 " />
                        <label className="mpris-text" label={displayTitle + (artist ? ` - ` + artist : "")} />
                        <box className="mpris-controls">
                            <button className="mpris-btn" onClicked={() => execAsync("playerctl previous")}>
                                <label label="󰒮" />
                            </button>
                            <button className="mpris-btn" onClicked={() => execAsync("playerctl play-pause")}>
                                <label label={status === "Playing" ? "󰏤" : "󰐊"} />
                            </button>
                            <button className="mpris-btn" onClicked={() => execAsync("playerctl next")}>
                                <label label="󰒭" />
                            </button>
                        </box>
                    </box>
                );
            })}
        </box>
    );
}

function Bar(monitor = 0) {
    return (
        <window
            className="bar-window"
            monitor={monitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        >
            <centerbox
                className="bar-container"
                startWidget={
                    <box className="left-modules">
                        <box className="module logo-module">
                            <label className="logo" label="❄️ NixOS" />
                        </box>
                        <Workspaces />
                    </box>
                }
                centerWidget={
                    <box className="center-modules">
                        <button className="module clock-module" onClicked={() => App.toggle_window("calendar-popup")}>
                            <label className="clock" label={bind(time)} />
                        </button>
                        <MprisModule />
                    </box>
                }
                endWidget={
                    <box className="right-modules">
                        <box className="module cpu-ram-module">
                            <label className="cpu" label={bind(cpuRaw).as(c => `󰍛 ` + c.trim() + `%`)} />
                            <label className="ram" label={bind(ramRaw).as(r => ` 󰘚 ` + r.trim() + `%`)} />
                        </box>
                        <box className="module wifi-module">
                            <label className="wifi" label={bind(wifiRaw).as(w => {
                                const ssid = w.trim();
                                return ssid ? `󰤨 ` + ssid : "󰤮 Disconnected";
                            })} />
                        </box>
                        <button className="module volume-module" onClicked={() => App.toggle_window("volume-popup")}>
                            <label className="volume" label={bind(volumeRaw).as(v => {
                                if (!v) return "󰕾 --%";
                                if (v.includes("[MUTED]")) return "󰝟 Muted";
                                const num = parseFloat(v.replace("Volume: ", "").trim());
                                const pct = Math.round(num * 100);
                                let icon = "󰕾";
                                if (pct === 0) icon = "󰝟";
                                else if (pct < 30) icon = "󰕿";
                                else if (pct < 70) icon = "󰖀";
                                return icon + ` ` + pct + `%`;
                            })} />
                        </button>
                        <box className="module battery-module">
                            <label className="battery" label={bind(batteryRaw).as(b => {
                                if (!b) return "󰂎 --%";
                                const parts = b.split(" ");
                                const cap = parseInt(parts[0]);
                                const status = parts[1] ? parts[1].trim() : "";
                                let icon = "󰁹";
                                if (status === "Charging") {
                                    icon = "󰂄";
                                } else {
                                    if (cap < 10) icon = "󰁺";
                                    else if (cap < 20) icon = "󰁻";
                                    else if (cap < 30) icon = "󰁼";
                                    else if (cap < 40) icon = "󰁽";
                                    else if (cap < 50) icon = "󰁾";
                                    else if (cap < 60) icon = "󰁿";
                                    else if (cap < 70) icon = "󰂀";
                                    else if (cap < 80) icon = "󰂁";
                                    else if (cap < 90) icon = "󰂂";
                                }
                                return icon + ` ` + cap + `%`;
                            })} />
                        </box>
                    </box>
                }
            />
        </window>
    );
}

function CalendarPopup(monitor = 0) {
    return (
        <window
            name="calendar-popup"
            className="calendar-popup"
            monitor={monitor}
            anchor={Astal.WindowAnchor.TOP}
            margins={[58, 0, 0, 0]}
            marginTop={58}
            margin_top={58}
            margin-top={58}
            exclusivity={Astal.Exclusivity.IGNORE}
            visible={false}
        >
            <box className="calendar-container" vertical={true} widthRequest={300} heightRequest={280}>
                <Gtk.Calendar visible={true} hexpand={true} vexpand={true} />
            </box>
        </window>
    );
}

function VolumePopup(monitor = 0) {
    return (
        <window
            name="volume-popup"
            className="volume-popup"
            monitor={monitor}
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
            margins={[58, 12, 0, 0]}
            marginTop={58}
            margin_top={58}
            margin-top={58}
            marginRight={12}
            margin_right={12}
            margin-right={12}
            exclusivity={Astal.Exclusivity.IGNORE}
            visible={false}
        >
            <box className="volume-popup-container" vertical={true} widthRequest={280}>
                <box className="volume-popup-header">
                    <label className="volume-popup-title" label="󰕾 Volume Control" />
                </box>
                <slider
                    className="volume-slider"
                    value={bind(volumeValue)}
                    min={0}
                    max={1.5}
                    hexpand={true}
                    onDragged={(self) => {
                        execAsync(`wpctl set-volume @DEFAULT_AUDIO_SINK@ ` + self.value.toFixed(2));
                    }}
                />
            </box>
        </window>
    );
}

function AppLauncher(monitor = 0) {
    const apps = new AstalApps.Apps();
    const query = Variable("");
    const selectedIndex = Variable(0);

    const getFilteredApps = (q) => {
        if (!q) {
            return apps.list.slice(0, 6);
        }
        return apps.fuzzy_query(q).slice(0, 6);
    };

    // Reset selected index when query changes
    query.subscribe(() => selectedIndex.set(0));

    const onActivate = (app) => {
        if (app) {
            app.launch();
            App.toggle_window("applauncher");
        }
    };

    const entryRef = Variable(null);

    return (
        <window
            name="applauncher"
            className="applauncher"
            monitor={monitor}
            anchor={Astal.WindowAnchor.TOP}
            margins={[100, 0, 0, 0]}
            marginTop={100}
            margin_top={100}
            margin-top={100}
            layer={Astal.Layer.OVERLAY}
            keymode={Astal.Keymode.EXCLUSIVE}
            exclusivity={Astal.Exclusivity.IGNORE}
            visible={false}
            setup={(self) => {
                // Focus the entry when the window becomes visible
                self.hook(self, "notify::visible", (win) => {
                    if (win.visible) {
                        query.set(""); // Clear query when opening
                        const entry = entryRef.get();
                        if (entry) {
                            entry.text = "";
                            entry.grab_focus();
                        }
                    }
                });
            }}
            onKeyPressEvent={(self, event) => {
                const [, keyval] = event.get_keyval();
                const currentList = getFilteredApps(query.get());

                if (keyval === 65307) { // Escape
                    App.toggle_window("applauncher");
                    return true;
                } else if (keyval === 65364) { // Down
                    if (selectedIndex.get() < currentList.length - 1) {
                        selectedIndex.set(selectedIndex.get() + 1);
                    }
                    return true;
                } else if (keyval === 65362) { // Up
                    if (selectedIndex.get() > 0) {
                        selectedIndex.set(selectedIndex.get() - 1);
                    }
                    return true;
                } else if (keyval === 65293 || keyval === 65421) { // Enter
                    const idx = selectedIndex.get();
                    if (currentList[idx]) {
                        onActivate(currentList[idx]);
                    }
                    return true;
                }
                return false;
            }}
        >
            <box className="launcher-container" vertical={true} widthRequest={500}>
                <box className="search-bar" vertical={false}>
                    <label className="search-icon" label="" />
                    <entry
                        className="search-entry"
                        hexpand={true}
                        placeholderText="Search apps..."
                        onChanged={(self) => query.set(self.text)}
                        setup={(self) => entryRef.set(self)}
                        onActivate={() => {
                            const currentList = getFilteredApps(query.get());
                            const idx = selectedIndex.get();
                            if (currentList[idx]) {
                                onActivate(currentList[idx]);
                            }
                        }}
                    />
                </box>
                
                <box className="results-list" vertical={true}>
                    {bind(query).as(q => {
                        const currentList = getFilteredApps(q);
                        if (currentList.length === 0) {
                            return (
                                <box className="no-results" halign={Gtk.Align.CENTER}>
                                    <label label="No apps found." />
                                </box>
                            );
                        }
                        return currentList.map((app, idx) => {
                            const itemClass = bind(selectedIndex).as(sIdx => 
                                sIdx === idx ? "launcher-item selected" : "launcher-item"
                            );
                            
                            return (
                                <button
                                    className={itemClass}
                                    onClicked={() => onActivate(app)}
                                >
                                    <box vertical={false} className="launcher-item-content">
                                        <icon 
                                            icon={app.icon_name || "application-x-executable"} 
                                            setup={(self) => self.pixel_size = 32}
                                            className="app-icon"
                                        />
                                        <box vertical={true} className="app-details" valign={Gtk.Align.CENTER}>
                                            <label className="app-name" label={app.name} halign={Gtk.Align.START} />
                                            {app.description && (
                                                <label className="app-description" label={app.description} halign={Gtk.Align.START} max_width_chars={50} ellipsize={3} />
                                            )}
                                        </box>
                                    </box>
                                </button>
                            );
                        });
                    })}
                </box>
            </box>
        </window>
    );
}

const getSavedWallpaper = () => {
    try {
        const path = exec("cat /home/gian/.cache/ags/current_wallpaper.txt 2>/dev/null").trim();
        if (path && exec(`test -f "${path}" && echo yes || echo no`).trim() === "yes") {
            return path;
        }
    } catch (e) {}
    return "/home/gian/.config/ags/wallpaper.jpg";
};

const currentWallpaper = Variable(getSavedWallpaper());

function Wallpaper(monitor = 0) {
    return (
        <window
            name={`wallpaper${monitor}`}
            className="wallpaper-window"
            monitor={monitor}
            exclusivity={Astal.Exclusivity.IGNORE}
            layer={Astal.Layer.BACKGROUND}
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        >
            <box 
                className="wallpaper-box" 
                setup={(self) => {
                    self.hook(currentWallpaper, () => {
                        self.css = `background-image: url('file://${currentWallpaper.get()}');`;
                    });
                    self.css = `background-image: url('file://${currentWallpaper.get()}');`;
                }}
            />
        </window>
    );
}

function WallpaperPicker(monitor = 0) {
    const wallpapersList = Variable([]);

    const updateWallpapersList = () => {
        execAsync(["sh", "-c", "ls /home/gian/Pictures/Wallpapers/*.{jpg,jpeg,png,webp} 2>/dev/null"])
            .then(out => {
                const list = out.split("\n").map(f => f.trim()).filter(f => f !== "");
                wallpapersList.set(list);
            })
            .catch(() => {
                wallpapersList.set([]);
            });
    };

    const chunkArray = (arr, size) => {
        const chunked = [];
        for (let i = 0; i < arr.length; i += size) {
            chunked.push(arr.slice(i, i + size));
        }
        return chunked;
    };

    return (
        <window
            name="wallpaperpicker"
            className="wallpaperpicker"
            monitor={monitor}
            anchor={Astal.WindowAnchor.TOP}
            margins={[100, 0, 0, 0]}
            marginTop={100}
            margin_top={100}
            margin-top={100}
            layer={Astal.Layer.OVERLAY}
            keymode={Astal.Keymode.EXCLUSIVE}
            exclusivity={Astal.Exclusivity.IGNORE}
            visible={false}
            setup={(self) => {
                self.hook(self, "notify::visible", (win) => {
                    if (win.visible) {
                        updateWallpapersList();
                    }
                });
            }}
            onKeyPressEvent={(self, event) => {
                const [, keyval] = event.get_keyval();
                if (keyval === 65307) { // Escape
                    App.toggle_window("wallpaperpicker");
                    return true;
                }
                return false;
            }}
        >
            <box className="picker-container" vertical={true} widthRequest={550}>
                <box className="picker-header" vertical={false}>
                    <label className="picker-icon" label="󰸉" />
                    <label className="picker-title" label=" Select Wallpaper" />
                    <button 
                        className="picker-close-btn" 
                        halign={Gtk.Align.END} 
                        hexpand={true}
                        onClicked={() => App.toggle_window("wallpaperpicker")}
                    >
                        <label label="󰅖" />
                    </button>
                </box>
                
                <scrollable className="picker-scroll" heightRequest={400} propagateNaturalHeight={false}>
                    <box className="picker-grid" vertical={true}>
                        {bind(wallpapersList).as(list => {
                            if (list.length === 0) {
                                return (
                                    <box className="no-wallpapers" halign={Gtk.Align.CENTER}>
                                        <label label="No wallpapers found in ~/Pictures/Wallpapers" />
                                    </box>
                                );
                            }
                            
                            const rows = chunkArray(list, 3);
                            return rows.map(row => (
                                <box vertical={false} className="wallpaper-row">
                                    {row.map(wallpaperPath => (
                                        <button
                                            className="wallpaper-card"
                                            onClicked={() => {
                                                currentWallpaper.set(wallpaperPath);
                                                execAsync(["sh", "-c", `mkdir -p /home/gian/.cache/ags && echo "${wallpaperPath}" > /home/gian/.cache/ags/current_wallpaper.txt`]);
                                                App.toggle_window("wallpaperpicker");
                                            }}
                                        >
                                            <box vertical={true} className="wallpaper-card-content">
                                                <box 
                                                    className="wallpaper-card-thumbnail" 
                                                    css={`background-image: url('file://${wallpaperPath}');`}
                                                    widthRequest={140}
                                                    heightRequest={80}
                                                />
                                                <label 
                                                    className="wallpaper-card-label" 
                                                    label={wallpaperPath.split("/").pop()} 
                                                    maxWidthChars={14}
                                                    ellipsize={3}
                                                    halign={Gtk.Align.CENTER}
                                                />
                                            </box>
                                        </button>
                                    ))}
                                </box>
                            ));
                        })}
                    </box>
                </scrollable>
            </box>
        </window>
    );
}

App.start({
    css: "/home/gian/.config/ags/style.css",
    main: () => {
        App.add_window(Wallpaper(0));
        App.add_window(Bar(0));
        App.add_window(CalendarPopup(0));
        App.add_window(VolumePopup(0));
        App.add_window(AppLauncher(0));
        App.add_window(WallpaperPicker(0));
    }
});
