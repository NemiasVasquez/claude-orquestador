// Lee el registro de cualquier agente (agy, OpenCode, Gemini CLI, Qwen, Codex) y saca lo esencial.
// Uso: node extraer.js <registro> [--sesion | --respuesta]
const fs = require("fs");
const [, , ruta, modo] = process.argv;
const texto = fs.existsSync(ruta) ? fs.readFileSync(ruta, "utf8") : "";

let respuesta = "", sesion = "";
const denegadas = [], errores = [], comandos = [];

function visitar(e) {
  if (!e || typeof e !== "object") return;
  if (Array.isArray(e)) return e.forEach(visitar);
  // Sesión: agy conversation_id, OpenCode sessionID, Gemini/Qwen session_id, Codex thread_id.
  for (const k of ["conversation_id", "sessionID", "session_id", "thread_id"])
    if (typeof e[k] === "string" && e[k]) sesion = e[k];
  // Respuesta final.
  if (e.event === "result" && e.result) {
    if (e.result.response) respuesta = e.result.response;
    (e.result.denied_actions || []).forEach(d => denegadas.push(d.display_name || d.action));
  }
  if (e.type === "text" && e.part && e.part.text) respuesta = e.part.text;              // OpenCode
  if (typeof e.response === "string" && e.response) respuesta = e.response;            // Gemini CLI / Qwen
  if (e.type === "result" && typeof e.result === "string") respuesta = e.result;        // stream-json tipo Claude
  if (e.item && e.item.type === "agent_message" && e.item.text) respuesta = e.item.text; // Codex
  if (e.type === "assistant" && e.message && Array.isArray(e.message.content))
    e.message.content.forEach(c => c.type === "text" && c.text && (respuesta = c.text));
  // Comandos y errores.
  const cmd = (e.tool_info && e.tool_info.parameters && e.tool_info.parameters.CommandLine)
    || (e.part && e.part.state && e.part.state.input && e.part.state.input.command)
    || (e.item && e.item.type === "command_execution" && e.item.command);
  if (cmd) comandos.push(String(cmd));
  if (e.part && e.part.state && e.part.state.status === "error") errores.push(String(e.part.state.error));
  if (e.type === "error" && e.message) errores.push(String(e.message));
  if (e.error && typeof e.error === "object" && e.error.message) errores.push(String(e.error.message));
}

const lineas = texto.split(/\r?\n/);
let algunJson = false;
for (const l of lineas) {
  const t = l.trim();
  if (!t) continue;
  if (t.startsWith("----- cambio de agente")) {  // solo cuenta el último agente; los comandos (push) se conservan
    respuesta = ""; sesion = ""; denegadas.length = 0; errores.length = 0; continue;
  }
  if (t.startsWith("{") || t.startsWith("[")) {
    try { visitar(JSON.parse(t)); algunJson = true; continue; } catch {}
  }
  if (/error|denied|timeout|quota|rate.?limit|unauthori[sz]ed|login/i.test(t)) errores.push(t);
}
if (!algunJson) { try { visitar(JSON.parse(texto)); algunJson = true; } catch {} }
if (!respuesta && !algunJson) respuesta = texto.trim().slice(-1500);

if (modo === "--sesion") { process.stdout.write(sesion); process.exit(0); }
if (modo === "--respuesta") {
  const errs = [...new Set(errores)].slice(-3);
  process.stdout.write((respuesta || "").trim() || (errs.length ? "ERROR del agente:\n" + errs.join("\n") : "(sin respuesta)"));
  process.exit(0);
}

const pushes = [...new Set(comandos.filter(c => /\bgit\s+push\b/.test(c)))];
console.log("Sesión: " + (sesion || "?"));
console.log("Denegadas: " + (denegadas.length ? denegadas.join(", ") : "ninguna"));
if (pushes.length) console.log("ALERTA: el agente intentó publicar: " + pushes.join(" | "));
const unicos = [...new Set(errores.map(x => x.slice(0, 300)))];
if (unicos.length) console.log("Errores:\n  " + unicos.slice(-5).join("\n  "));
console.log("Respuesta final:\n  " + ((respuesta || "(vacía)").trim().slice(-1500).replace(/\n/g, "\n  ")));
