// Agrega a cada CLI instalado los MCP (markitdown, playwright, context7), las reglas deny y la skill de documentos.
// Uso: node configurar-agentes.js <dir-skill>   (lo llama instalar.sh; respalda cada archivo como *.bak-orq)
// No borra nada de lo que ya tengas: solo agrega lo que falta.
const fs = require("fs"), path = require("path"), os = require("os");
const { execSync } = require("child_process");
const HOME = os.homedir(), WIN = process.platform === "win32";
const DIR_SKILL = process.argv[2];

const existe = p => { try { fs.accessSync(p); return true; } catch { return false; } };
const hay = bin => { try { execSync((WIN ? "where " : "command -v ") + bin, { stdio: "ignore", shell: true }); return true; } catch { return false; } };
function respaldar(p) { if (existe(p) && !existe(p + ".bak-orq")) fs.copyFileSync(p, p + ".bak-orq"); }

// JSON con comentarios y comas finales (opencode.jsonc).
function leerJsonc(p) {
  if (!existe(p)) return {};
  let s = fs.readFileSync(p, "utf8").replace(/^\uFEFF/, ""), out = "", i = 0, enCadena = false;
  while (i < s.length) {
    const c = s[i], d = s[i + 1];
    if (enCadena) { out += c; if (c === "\\") { out += d; i += 2; continue; } if (c === '"') enCadena = false; i++; continue; }
    if (c === '"') { enCadena = true; out += c; i++; continue; }
    if (c === "/" && d === "/") { while (i < s.length && s[i] !== "\n") i++; continue; }
    if (c === "/" && d === "*") { i = s.indexOf("*/", i + 2) + 2; continue; }
    out += c; i++;
  }
  return JSON.parse(out.replace(/,(\s*[}\]])/g, "$1") || "{}");
}
const escribir = (p, obj) => { respaldar(p); fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, JSON.stringify(obj, null, 2) + "\n"); };

// Navegador para Playwright: Brave, Chrome o Edge (en ese orden).
const brave = WIN ? "C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe"
  : "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser";
const chrome = WIN ? "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
  : "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const playwrightArgs = ["-y", "@playwright/mcp", "--isolated"].concat(
  existe(brave) ? ["--browser=chrome", "--executable-path=" + brave]
    : existe(chrome) || hay("google-chrome") ? ["--browser=chrome"] : WIN ? ["--browser=msedge"] : []);
const python = WIN ? "python" : "python3";
const MCP = {
  playwright: { command: "npx", args: playwrightArgs },
  markitdown: { command: python, args: ["-m", "markitdown_mcp"] },
  context7: { command: "npx", args: ["-y", "@upstash/context7-mcp"] },
};
const DENY = ["git push", "git reset --hard", "git clean", "git merge", "git rebase", "git worktree", "rm -rf",
  "npm publish", "pnpm publish", "prisma migrate reset", "--force-reset", "ssh", "scp", "vercel", "gh"];
const VERIFICACION = ["git status", "git diff", "git log", "npm test", "npm run test", "npm run lint", "npm run build",
  "npm run typecheck", "npm run check", "pnpm test", "pnpm lint", "pnpm build", "pnpm typecheck", "pnpm check",
  "yarn test", "yarn build", "bun test", "npx tsc --noEmit", "npx vitest run", "npx playwright test", "node --test",
  "pytest", "python -m pytest", "go test ./...", "cargo test", "dotnet test"];
const hecho = [];

// mcpServers {command,args} — formato de agy, Gemini CLI y Qwen.
function mcpServers(p, nombre) {
  const j = leerJsonc(p); j.mcpServers = j.mcpServers || {};
  let n = 0; for (const [k, v] of Object.entries(MCP)) if (!j.mcpServers[k]) { j.mcpServers[k] = v; n++; }
  if (n) { escribir(p, j); hecho.push(`${nombre}: ${n} MCP en ${p}`); }
}
function skillDocumentos(dir, nombre) {
  const destino = path.join(dir, "documentos", "SKILL.md");
  fs.mkdirSync(path.dirname(destino), { recursive: true });
  fs.copyFileSync(path.join(DIR_SKILL, "guias", "documentos.md"), destino);
  hecho.push(`${nombre}: skill documentos en ${destino}`);
}

// agy (Antigravity CLI)
const agyDir = path.join(HOME, ".gemini", "antigravity-cli");
if (existe(agyDir)) {
  mcpServers(path.join(HOME, ".gemini", "config", "mcp_config.json"), "agy");
  const p = path.join(agyDir, "settings.json"), j = leerJsonc(p);
  j.permissions = j.permissions || {}; j.permissions.allow = j.permissions.allow || []; j.permissions.deny = j.permissions.deny || [];
  const add = (lista, r) => lista.includes(r) ? 0 : (lista.push(r), 1);
  let n = 0;
  for (const r of ["mcp(playwright/*)", "mcp(markitdown/*)", "mcp(context7/*)", ...VERIFICACION.map(c => `command(${c})`)]) n += add(j.permissions.allow, r);
  for (const c of DENY) n += add(j.permissions.deny, `command(${c})`);
  if (n) { escribir(p, j); hecho.push(`agy: ${n} reglas en ${p}`); }
  skillDocumentos(path.join(HOME, ".gemini", "config", "skills"), "agy");
}
// OpenCode
if (hay("opencode")) {
  const dir = path.join(HOME, ".config", "opencode");
  const p = existe(path.join(dir, "opencode.jsonc")) ? path.join(dir, "opencode.jsonc") : path.join(dir, "opencode.json");
  const j = leerJsonc(p); j.mcp = j.mcp || {}; let n = 0;
  for (const [k, v] of Object.entries(MCP)) if (!j.mcp[k]) { j.mcp[k] = { type: "local", command: [v.command, ...v.args], enabled: true }; n++; }
  j.permission = j.permission || {};
  if (typeof j.permission.bash !== "object") j.permission.bash = {};
  // "git push" → "git push*"; una sola palabra → "ssh *" (no "gh*", que bloquearía cualquier comando que empiece con gh);
  // opciones o subcomandos que pueden ir en cualquier lugar → "*--force-reset*".
  const patron = c => c.startsWith("-") || c.includes("prisma") || c === "vercel" ? `*${c}*` : c.includes(" ") ? `${c}*` : `${c} *`;
  for (const c of DENY) { const k = patron(c); if (!j.permission.bash[k]) { j.permission.bash[k] = "deny"; n++; } }
  if (!j.$schema) j.$schema = "https://opencode.ai/config.json";
  if (n) { escribir(p, j); hecho.push(`opencode: ${n} cambios en ${p}`); }
  skillDocumentos(path.join(dir, "skills"), "opencode");
}
// Gemini CLI y Qwen Code
if (hay("gemini")) mcpServers(path.join(HOME, ".gemini", "settings.json"), "gemini-cli");
if (hay("qwen")) mcpServers(path.join(HOME, ".qwen", "settings.json"), "qwen");
// Codex (TOML): agrega bloques [mcp_servers.x] que falten.
if (hay("codex")) {
  const p = path.join(HOME, ".codex", "config.toml"); let s = existe(p) ? fs.readFileSync(p, "utf8") : "", n = 0;
  const toml = v => "[" + v.map(x => `'${x}'`).join(", ") + "]";
  for (const [k, v] of Object.entries(MCP)) if (!s.includes(`[mcp_servers.${k}]`)) {
    s += `\n[mcp_servers.${k}]\ncommand = '${v.command}'\nargs = ${toml(v.args)}\n`; n++; }
  if (n) { respaldar(p); fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, s); hecho.push(`codex: ${n} MCP en ${p}`); }
}
console.log(hecho.length ? hecho.map(h => "  · " + h).join("\n") : "  · Nada que cambiar: ya estaba configurado.");
