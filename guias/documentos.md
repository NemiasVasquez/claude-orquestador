---
name: documentos
description: Leer, crear y editar PDF, Word (.docx), Excel (.xlsx/.csv) y PowerPoint (.pptx), y convertir entre formatos. Usar cuando la tarea pida generar o revisar un documento, una hoja de cálculo o una presentación.
---

# Documentos (PDF, Word, Excel, PowerPoint)

Todo con Python (`python`, o `python3` en macOS/Linux) y librerías libres ya instaladas. En Windows, si los acentos salen mal en consola, usa
`python -X utf8` (los archivos están bien; es solo la salida). Escribe el código en un script dentro de
`docs/agentes/reportes/<ID>-scripts/` (en una consulta, en el directorio actual) y córrelo con `python <script>`; no uses `python -c` largos.

## Leer cualquier formato

- **Rápido, a Markdown:** `python -m markitdown archivo.pdf` (también .docx, .xlsx, .pptx, .html, .csv). Con MCP:
  herramienta `markitdown` → `convert_to_markdown` con `file:///C:/ruta/absoluta`.
- PDF con tablas o coordenadas: `pdfplumber` (`page.extract_text()`, `page.extract_tables()`).
- PDF a texto simple: `pdftotext -layout archivo.pdf -`.

## Crear o editar

| Formato | Librería | Notas |
|---|---|---|
| Word | `python-docx` (`from docx import Document`) | Estilos con `doc.styles`, tablas con `doc.add_table`; para plantillas, abre el .docx y reemplaza texto por *runs* sin perder formato |
| Excel | `openpyxl` | Escribe **fórmulas** (`ws["C2"] = "=A2*B2"`), no valores calculados en Python. `pandas` solo para analizar datos |
| PowerPoint | `python-pptx` (`from pptx import Presentation`) | Usa los layouts del archivo base; no superpongas cuadros de texto |
| PDF nuevo | `reportlab` | Unir, dividir o rotar: `pypdf` (`PdfReader`, `PdfWriter`) |
| Formularios PDF | `pypdf` (`writer.update_page_form_field_values`) | |

## Convertir y verificar

- LibreOffice (`soffice`; si no está en el PATH: Windows `C:\Program Files\LibreOffice\program\soffice.exe`, macOS
  `/Applications/LibreOffice.app/Contents/MacOS/soffice`):
  - a PDF: `soffice --headless --convert-to pdf --outdir <dir> <archivo>`
  - recalcular las fórmulas de un .xlsx: `soffice --headless --convert-to xlsx --outdir <dir> <archivo>`, después
    ábrelo con `openpyxl.load_workbook(ruta, data_only=True)` y revisa que no haya `#REF!`, `#DIV/0!`, `#VALUE!` ni
    `#NAME?`.
- `pandoc` (si no está en el PATH, en Windows: `%LOCALAPPDATA%\Pandoc\pandoc.exe`): Markdown ↔ docx/html
  (`pandoc in.md -o out.docx`).
- Revisión visual: convierte a PDF y ábrelo con Playwright (`file:///...pdf`), o haz una captura.

## Antes de terminar

1. Abre el archivo generado con `python -m markitdown` y comprueba que el contenido esté completo.
2. En Excel, cero errores de fórmula tras recalcular.
3. Anota en el reporte: ruta del archivo, cómo lo verificaste y la salida (las últimas líneas).
