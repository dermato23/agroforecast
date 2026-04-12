from pypdf import PdfReader
import sys

def extract(path, out):
    reader = PdfReader(path)
    text = ""
    for idx, page in enumerate(reader.pages):
        text += f"--- PAGE {idx} ---\n"
        text += page.extract_text() + "\n"
        if idx > 4: break
    with open(out, 'w', encoding='utf-8') as f:
        f.write(text)

extract(r'c:\Users\nesto\OneDrive\Documentos\automatizacion\Antigravity\Desarrollos\Forecast\documents\Boletin_diario_20260401.pdf', 'corabastos.txt')
extract(r'c:\Users\nesto\OneDrive\Documentos\automatizacion\Antigravity\Desarrollos\Forecast\documents\Boletin DIario Sipsa.pdf', 'sipsa_diario.txt')
extract(r'c:\Users\nesto\OneDrive\Documentos\automatizacion\Antigravity\Desarrollos\Forecast\documents\Boletin Semanal Sipsa.pdf', 'sipsa_semanal.txt')
