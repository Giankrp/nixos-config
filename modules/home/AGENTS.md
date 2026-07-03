# Gian Agent Global Rules

## 1. COMPORTAMIENTO GENERAL
- Si la instrucción del usuario es vaga o genérica en aspectos clave de arquitectura o lógica de negocio, DETENTE y pide aclaraciones/contexto antes de proponer código.
- REGLA DE ORO DE DEPENDENCIAS: NUNCA instales nada automáticamente. Analiza las mejores opciones actuales, preséntalas con pros/contras, sugiere la más óptima y espera confirmación.
- Al finalizar o proponer cambios, explica detalladamente el resultado obtenido.
- RECONOCIMIENTO DE ENTORNO: Si detectas que el proyecto no está dockerizado y requiere servicios externos (como bases de datos o servicios en segundo plano), pregunta activamente si deseas agregar Docker, priorizando la comunicación mediante `docker-compose`.
- REGLA DEL DIFF MÍNIMO: Haz siempre el cambio más pequeño y localizado posible. No reformatees, reorganices ni reescribas código no relacionado con la tarea a menos que se solicite explícitamente.
- PRESERVACIÓN DE COMENTARIOS: Mantén intactos todos los comentarios, documentación y docstrings del código que no esté directamente relacionado con tus cambios.

## 2. STACK TYPESCRIPT (Proyectos Web/JS)
- Usa exclusivamente `pnpm` como gestor de paquetes (prohibido npm/yarn).
- Para análisis estático y formateo, usa exclusivamente `oxlint` y `oxfmt` (con fallback a `prettier` o `biome` si `oxfmt` presenta limitaciones de compatibilidad en el proyecto).

## 3. STACK GO (Entorno Principal)
- Herramienta de Hot Reload: Configura y asume el uso de `air`.
- Frameworks Web: Prioriza el uso de la librería estándar o `echo`.
- Persistencia/Base de Datos: Usa `GORM` por defecto, pero PREGUNTA explícitamente si prefieres usar `sqlx` para la capa de persistencia en este caso específico.
- Interfaces de Terminal (TUI): Usa las librerías de Charmbracelet (`bubbletea`, `lipgloss`, etc.) siguiendo las arquitecturas recomendadas y patrones de diseño propios del ecosistema Charmbracelet (no todo necesita seguir la arquitectura Elm estrictamente, usa el patrón adecuado para cada herramienta).
- Automatización: Usa un archivo `justfile` con la herramienta `just` para centralizar comandos y scripts.
- Linters y Formateadores: Usa `golangci-lint` (versiones recientes/v2) y `gofumpt` para formatear el código de Go, integrando de ser posible `gofumpt` dentro de `golangci-lint` para mantener el proceso centralizado.

## 4. VALIDACIÓN Y PRUEBAS (TESTING)
- **Pruebas mínimas:** Genera siempre pruebas unitarias mínimas que validen cualquier lógica modificada o añadida.
- **Criterio de aceptación:** No consideres una tarea como completada hasta que todas las pruebas del proyecto pasen con éxito y compilen sin errores.
- **Prioridad del código sobre las pruebas:** El test debe validar el comportamiento del código, y no el código adaptarse artificialmente para forzar que el test pase. Si una prueba falla, analiza si hay un error de lógica real (bug) en el código original antes de modificarlo; si el código original funciona de forma correcta y esperada, corrige la definición o los valores de la prueba.
