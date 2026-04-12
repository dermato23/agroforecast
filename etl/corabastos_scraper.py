import requests
from bs4 import BeautifulSoup
import pyodbc
from datetime import datetime

# Configuración para la Base de Datos Local SQL Server
SERVER_NAME = r'NESTORZ13\SQLEXPRESS'
DATABASE_NAME = 'AgroForecastDB'

def conectar_bd():
    try:
        conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME};Trusted_Connection=yes;'
        conn = pyodbc.connect(conn_str)
        return conn
    except Exception as e:
        print(f"Error conectando a SQL Server: {e}")
        return None

def fetch_corabastos_bulletin():
    """
    Descarga y parsea el boletín diario de precios desde la página de Corabastos.
    """
    print(f"Iniciando extracción de Corabastos: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # URL del boletín diario (esta URL puede variar según la estructura real de Corabastos, apuntamos a la raíz para test)
    url = "https://www.corabastos.com.co/" 
    
    # Headers para simular un navegador real y evitar bloqueos (User-Agent)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    try:
        print("Realizando petición HTTP al portal de Corabastos...")
        response = requests.get(url, headers=headers, timeout=30)
        
        if response.status_code == 200:
            print("Página descargada exitosamente. Parseando HTML con BeautifulSoup...")
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # TODO: Implementar la lógica real de selectores CSS (find, find_all)
            # Esto depende totalmente de cómo está construida la tabla del día de hoy.
            # Ejemplo ficticio:
            # table = soup.find('table', {'id': 'precios-del-dia'})
            # rows = table.find_all('tr')
            
            print("\nEstructura HTML base cargada en memoria.")
            print("Nota: El scraping exacto requiere selectores CSS precisos del HTML actual.")
            print("Para este prototipo ETL, simularemos la inserción de 2 registros extraídos.\n")
            
            # Simulación de datos extraídos (Scraping Mock)
            datos_extraidos = [
                {'producto': 'Papa Pastusa', 'unidad': 'KG', 'promedio': 1610.50},
                {'producto': 'Cebolla Cabezona Blanca', 'unidad': 'KG', 'promedio': 2050.00}
            ]
            
            guardar_en_bd(datos_extraidos)

        else:
            print(f"Error al acceder a Corabastos. Código de estado: {response.status_code}")

    except requests.exceptions.Timeout:
        print("El portal de Corabastos está tardando mucho en responder (Timeout).")
    except requests.exceptions.RequestException as e:
        print(f"Error de red: {e}")

def guardar_en_bd(datos):
    print("Conectando a SQL Server para inyectar los datos del boletín...")
    conn = conectar_bd()
    if not conn:
        return
        
    cursor = conn.cursor()
    # MarketID 1 = Corabastos
    market_id = 1
    # SourceTypeID 2 = Scraping Directo
    source_type_id = 2 
    
    # Aseguramos que el SourceType exista
    cursor.execute("IF NOT EXISTS (SELECT SourceTypeID FROM SourceTypes WHERE SourceTypeID=2) INSERT INTO SourceTypes (SourceTypeID, SourceName) VALUES (2, 'Corabastos WebScraping')")

    registros_insertados = 0
    hoy = datetime.now()

    try:
        for item in datos:
            # Bussiness Logic: Mapear el nombre extraído (ej: 'Papa Pastusa') al ProductID de nuestra BD
            # En producción esto usaría la tabla ProductAliases para ser resiliente a errores tipográficos.
            cursor.execute("SELECT ProductID FROM Products WHERE StandardName = ?", item['producto'])
            row = cursor.fetchone()
            
            if row:
                product_id = row[0]
                # Insertar el registro histórico
                cursor.execute("""
                    INSERT INTO PriceLogs (ProductID, MarketID, SourceTypeID, ReportDate, AvgPrice, ReportedUnit, StandardizedPricePerKg, CreatedAt)
                    VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())
                """, (product_id, market_id, source_type_id, hoy, item['promedio'], item['unidad'], item['promedio']))
                registros_insertados += 1
                
        conn.commit()
        print(f"✅ Éxito: Se integraron {registros_insertados} precios nuevos a la Base de Datos.")

    except Exception as e:
        conn.rollback()
        print(f"Error insertando en la BD: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    fetch_corabastos_bulletin()
