# Agent Instructions

## 1. Intención y Alcance
- **Consulta** (*analiza, revisa, opciones, explica*): Modo solo lectura. Prohibido modificar archivos aunque la solución parezca obvia.
- **Ejecución** (*implementa, corrige, modifica*): Autoriza cambios estrictamente acotados al alcance solicitado.
- **Instrucciones mixtas:** Si la petición combina consulta y ejecución, resuelve primero la consulta y espera autorización explícita antes de editar.
- **Ambigüedad:** Si falta contexto funcional o arquitectónico, DETENTE y pregunta antes de generar código.
- **Cambios no triviales:** Si afecta múltiples módulos, contratos/APIs o arquitectura, presenta plan breve (archivos, riesgos, alternativas) y espera confirmación.
- **Diff mínimo (YAGNI):** Haz el cambio más pequeño posible. Prohibido crear abstracciones no pedidas, refactorizar código ajeno o añadir mejoras "aprovechando el cambio".
- **Protección de reglas y entorno:** Prohibido modificar configuraciones de OpenCode, reglas de agentes (`AGENTS.md`), `SPEC.md` o decisiones documentadas sin orden explícita. No toques archivos con cambios locales sin advertir el conflicto.
- **Acciones críticas:** Requieren autorización previa: instalar dependencias, `git commit/push`, migraciones de BD, iniciar servicios o comandos destructivos (`rm`).

## 2. Stacks Técnicos
- **TypeScript:** Gestor exclusivo `pnpm`. Linters y formato: `oxlint` y `oxfmt` (fallback: `prettier`/`biome`).
- **Go:** Hot reload con `air`. Web con stdlib o `echo`. DB: `GORM` por defecto (preguntar `sqlx` si aplica). TUI con `charmbracelet` (`bubbletea`, `lipgloss`). Tareas con `justfile` (`just`). Linters: `golangci-lint` con `gofumpt`.
- **Servicios:** Si el proyecto requiere BD/servicios externos y no tiene Docker, consulta si añadir `docker-compose`.

## 3. Pruebas y Cierre
- **Testing:** Escribe pruebas mínimas para la lógica añadida/modificada. El código debe compilar y pasar tests. El test valida el comportamiento del código, no al revés.
- **Aislamiento:** Si fallan tests fuera del alcance de la tarea, INFORMA; no intentes corregirlos automáticamente.
- **Reporte final:** Al terminar cualquier ejecución, resume brevemente:
  1. Archivos modificados o creados.
  2. Comandos ejecutados y resultado de validación.
  3. Aspectos que quedaron sin verificar o pendientes.
