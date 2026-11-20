---
name: commits
description: Crea commits atómicos y estructurados en cualquier repositorio, deduciendo el scope del área tocada y respetando las reglas del proyecto. Úsalo cuando el usuario pida hacer commits, guardar el trabajo o separar cambios.
---

# Commits

## Cuándo usarla

- Cuando el usuario solicite explícitamente guardar el trabajo, hacer commits o separar cambios pendientes.
- **PROHIBIDO** hacer commits de forma proactiva o sin que el usuario lo haya ordenado expresamente.

## Flujo de Trabajo

### 1. Inspección de contexto y estilo del repositorio
1. Leer reglas del proyecto (`AGENTS.md`, `CONTRIBUTING.md`, etc.).
2. Revisar los últimos commits para detectar el idioma, estilo y convenciones establecidas:
   ```bash
   git log -10 --oneline
   ```
3. Ejecutar diagnóstico de cambios:
   ```bash
   git status --short
   git diff
   ```

### 2. Detección de idioma y formato
- **Idioma:** Español por defecto. Si el repositorio tiene un historial (`git log -10`) escrito consistentemente en inglés u otro idioma, adaptarse a ese idioma para mantener coherencia.
- **Formato:**
  - Si el proyecto usa **Conventional Commits** (ej. `feat(api): ...`, `fix(ui): ...`), seguir esa estructura.
  - Si no, usar `<scope>: <verbo en imperativo>` (ej. `api: agrega endpoint de usuarios`, `config: actualiza dependencias de NixOS`).

### 3. Deducción dinámica del Scope (Área tocada)
- **El scope NO proviene de una lista estática:** Se deduce lógicamente del módulo, componente o subsistema modificado:
  - Ejemplos: `api`, `web`, `cli`, `tui`, `auth`, `config`, `docs`, `db`, etc.
  - Si el proyecto define scopes o componentes propios en su documentación o historial, respetarlos.
- **Cambios que cruzan múltiples áreas:**
  - **Separables:** Dividir en commits atómicos separados por área funcional.
  - **Inseparables (atómicos por necesidad):** Usar el área dominante en el título del commit y explicar las implicaciones en las demás áreas en el cuerpo del mensaje.

### 4. Atomicidad y separación de responsabilidades
- **Un commit = una unidad funcional.**
- **Tests con el código:** Incluir siempre las pruebas unitarias/integración en el mismo commit del código que prueban.
- **Documentación separada:** Cuando sea posible, separar commits de documentación (`docs: ...`) de los commits de código o lógica.

### 5. Preparación (Staging) seguro y explícito
- **NUNCA usar `git add .` ni `git add -A`:** Añadir exclusivamente los archivos correspondientes a la unidad de trabajo:
  ```bash
  git add ruta/al/archivo1 ruta/al/archivo2
  ```
  O usar adición interactiva/por hunks (`git add -p`) si hay cambios mixtos en un mismo archivo.
- **Revisión obligatoria de staging:** Antes de crear el commit, verificar que únicamente los cambios previstos están incluidos:
  ```bash
  git diff --cached
  ```

### 6. Ejecución del Commit y manejo de Git Hooks
- Ejecutar el commit con mensaje descriptivo:
  ```bash
  git commit -m "<mensaje>"
  ```
- **Hooks de pre-commit / linters:**
  - Si un hook pre-commit (husky, lefthook, pre-commit, formatters) formatea archivos automáticamente o falla:
    1. Revisar el resultado con `git status`.
    2. Si los cambios del hook son correctos, añadirlos al staging con `git add <archivo>`.
    3. Reintentar el commit.
  - **PROHIBIDO** eludir hooks usando `--no-verify` salvo orden explícita y fundada del usuario.

### 7. Reglas de Entrega y Atribución
- **Sin atribución de IA:** Prohibido incluir `Co-Authored-By`, pies de firma o referencias a modelos de IA en el mensaje del commit.
- **Sin push automático:** **NUNCA** ejecutar `git push` sin autorización expresa y directa del usuario.
