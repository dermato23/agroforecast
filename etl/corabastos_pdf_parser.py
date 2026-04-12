import sys
import json
import re
import urllib.request
import io
from urllib.error import URLError
from pypdf import PdfReader

def get_latest_boletin_url():
    """Scrapes Corabastos page to find the latest PDF url."""
    url = "https://corabastos.com.co/boletin-de-precios/"
    # Fake user agent to bypass fortinet/waf restrictions just in case
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    try:
        html = urllib.request.urlopen(req).read().decode('utf-8')
    except Exception as e:
        raise Exception(f"Error fetching Corabastos website: {e}")
        
    # Search for PDF links that look like daily bulletins
    # They often have "Boletin" in the name or the page has a clear button
    # Let's extract any .pdf link from wp-content/uploads/
    pdf_links = re.findall(r'href="(https://[^"]+?\.pdf)"', html)
    if not pdf_links:
        raise Exception("No PDF links found on the page.")
        
    # Usually the first PDF is the most recent daily bulletin
    return pdf_links[0]

def parse_corabastos_pdf_bytes(pdf_bytes):
    results = []
    
    # Regex to grab tabular data
    pattern = re.compile(
        r"^(.*?)\s+(KILO|BULTO|BULTOS|CANASTILLA|CAJA|ATADO|PAQUETE|BOLSA|LIBRA|LIBRAS|UNIDAD)\s+(\d+)\s+(KILO|BULTO|BULTOS|CANASTILLA|CAJA|ATADO|PAQUETE|BOLSA|LIBRA|LIBRAS|UNIDAD)\s+\$([\d,]+)\s+\$([\d,]+)(?:\s+\$([\d,]+))?\s+(Estable|Subio|Bajo)",
        re.IGNORECASE
    )

    reader = PdfReader(pdf_bytes)
    
    for page in reader.pages:
        text = page.extract_text()
        if not text: continue
            
        for line in text.split('\n'):
            line = line.strip()
            match = pattern.search(line)
            if match:
                try:
                    p_extra = int(match.group(5).replace(',', ''))
                    p_primera = int(match.group(6).replace(',', ''))
                    p_unidad = int(match.group(7).replace(',', '')) if match.group(7) else 0
                    
                    item = {
                        "producto": match.group(1).strip(),
                        "presentacion": match.group(2).strip(),
                        "cantidad": int(match.group(3)),
                        "unidad": match.group(4).strip(),
                        "precio_extra": p_extra,
                        "precio_primera": p_primera,
                        "precio_unidad": p_unidad,
                        "variacion": match.group(8).strip(),
                        "ciudad": "Bogotá"
                    }
                    results.append(item)
                except Exception:
                    pass
    
    return results

if __name__ == "__main__":
    try:
        # Step 1: Automatically find the latest PDF link
        pdf_url = get_latest_boletin_url()
        
        # Step 2: Download the PDF into memory
        req = urllib.request.Request(pdf_url, headers={'User-Agent': 'Mozilla/5.0'})
        pdf_data = urllib.request.urlopen(req).read()
        
        # Step 3: Parse PDF data
        data = parse_corabastos_pdf_bytes(io.BytesIO(pdf_data))
        
        # Output strictly valid JSON to stdout
        print(json.dumps(data, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)
