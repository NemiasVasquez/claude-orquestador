#!/usr/bin/env bash
# Instala la skill orquestar-agentes para una persona del equipo. Se corre en su propia terminal (bash / Git Bash):
#
#   git clone <repo> ~/.claude/skills/orquestar-agentes
#   bash ~/.claude/skills/orquestar-agentes/instalar.sh [--agentes "opencode gemini-cli qwen codex"] [--sin-programas]
#
# Hace: instala los CLI de agentes que falten, las librerías de documentos (Python) y LibreOffice/pandoc,
# configura en cada CLI los MCP (Playwright, markitdown, Context7), las reglas deny y la skill de documentos,
# y crea tu config personal. Respalda cada archivo que toca como *.bak-orq. Se puede correr varias veces.
set -u
DIR_SKILL=$(cd "$(dirname "$0")" && pwd)
AGENTES="opencode gemini-cli"
PROGRAMAS=1
while [ $# -gt 0 ]; do
  case $1 in
    --agentes) AGENTES=$2; shift 2 ;;
    --sin-programas) PROGRAMAS=0; shift ;;
    *) echo "Opción desconocida: $1"; exit 2 ;;
  esac
done
paso() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }
falta() { ! command -v "$1" >/dev/null 2>&1; }

paso "Requisitos"
for c in git node npm; do falta $c && { echo "Falta $c: instálalo y vuelve a correr."; exit 2; }; done
PY=$(command -v python || command -v python3) || { echo "Falta Python 3: instálalo y vuelve a correr."; exit 2; }
echo "git, node, npm y $("$PY" --version) listos."

if [ "$(basename "$(dirname "$DIR_SKILL")")" != skills ]; then
  echo "AVISO: la skill debe quedar en ~/.claude/skills/orquestar-agentes (está en $DIR_SKILL)."
fi

paso "CLI de agentes: $AGENTES"
for a in $AGENTES; do
  case $a in
    opencode)   falta opencode && npm i -g opencode-ai ;;
    gemini-cli) falta gemini && npm i -g @google/gemini-cli ;;
    qwen)       falta qwen && npm i -g @qwen-code/qwen-code ;;
    codex)      falta codex && npm i -g @openai/codex ;;
    agy)        falta agy && falta agy.exe && echo "agy: instala Antigravity CLI desde la web de Google Antigravity (no va por npm)." ;;
    *) echo "No sé instalar '$a': agrega su adaptador en agentes/$a.sh." ;;
  esac
done

paso "Librerías de documentos (Python)"
"$PY" -m pip install -q pypdf pdfplumber reportlab python-docx openpyxl pandas python-pptx \
  "markitdown[all]" markitdown-mcp && echo "Listas."

if [ $PROGRAMAS = 1 ]; then
  paso "LibreOffice y pandoc"
  if command -v winget >/dev/null; then
    for id in TheDocumentFoundation.LibreOffice JohnMacFarlane.Pandoc; do
      winget list --id $id -e >/dev/null 2>&1 || winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
    done
  elif command -v brew >/dev/null; then
    falta soffice && brew install --cask libreoffice; falta pandoc && brew install pandoc
  else
    echo "Instálalos con tu gestor de paquetes (p. ej. sudo apt install libreoffice pandoc poppler-utils)."
  fi
fi

paso "Configurar los agentes (MCP, reglas deny, skill de documentos)"
node "$DIR_SKILL/scripts/configurar-agentes.js" "$DIR_SKILL"

paso "Config personal"
CONFIG=$HOME/.config/orquestar-agentes/config
if [ -f "$CONFIG" ]; then echo "Ya existe: $CONFIG"
else mkdir -p "$(dirname "$CONFIG")" && cp "$DIR_SKILL/config.ejemplo" "$CONFIG" && echo "Creada: $CONFIG (revisa la sección de permisos)"; fi
command -v setx >/dev/null && setx PYTHONUTF8 1 >/dev/null 2>&1

paso "Claude usa la skill en todo proyecto"
MD=$HOME/.claude/CLAUDE.md
LINEA="- Para cualquier tarea o consulta que se pueda delegar, usa la skill orquestar-agentes: Claude reparte el trabajo entre los agentes del CLI y valida; no implementa lo que un agente pueda hacer."
if grep -qs "orquestar-agentes" "$MD"; then echo "Ya está en $MD"
else mkdir -p "$(dirname "$MD")" && printf '\n%s\n' "$LINEA" >> "$MD" && echo "Agregado a $MD"; fi

paso "Estado"
bash "$DIR_SKILL/scripts/agentes.sh"
cat <<'EOF'

Falta solo iniciar sesión una vez en cada CLI que vayas a usar (en tu terminal):
  opencode auth login   (opcional: los modelos opencode/* gratis no lo piden)
  gemini                (en la carpeta que contiene tus repos: Login with Google + Trust parent folder)
  qwen                  (opcional y de pago: QwenCloud o Third-party con API key)
  codex login           (cuenta de ChatGPT)
  agy                   (cuenta de Google)
Después, en Claude Code: /orquestar-agentes <lo que quieres hacer>
EOF
