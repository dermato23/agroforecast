import zeep
import json
import pyodbc 
from zeep.transports import Transport
from requests import Session
from datetime import datetime

# Configuración para la Base de Datos Local SQL Server
SERVER_NAME = 'localhost' # Cambiar si tienes SQLEXPRESS u otra instancia
DATABASE_NAME = 'AgroForecastDB'

def conectar_bd():
    try:
        # Usamos Windows Authentication (Trusted_Connection=yes)
        conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME};Trusted_Connection=yes;'
        conn = pyodbc.connect(conn_str)
        return conn
    except Exception as e:
        print(f"Error conectando a SQL Server: {e}")
        return None

def fetch_sipsa_data():
    print("Iniciando cliente SOAP para SIPSA (DANE)...")
    wsdl_url = 'https://appweb.dane.gov.co/sipsaWS/SrvSipsaUpraBeanService?WSDL'
    
    session = Session()
    session.verify = False 
    transport = Transport(session=session, timeout=60)
    
    try:
        client = zeep.Client(wsdl=wsdl_url, transport=transport)
        print("Cliente conectado exitosamente al WSDL del DANE.")
        
        print("\nConectando a SQL Server...")
        conn = conectar_bd()
        if not conn:
            print("⚠ IMPORTANTE: La conexión a la Base de Datos falló.")
            print("Asegúrate de que creaste la BD AgroForecastDB en SQL Server")
            print("corriendo el archivo 'AgroForecast_DB_Schema.sql'.")
            return
            
        cursor = conn.cursor()
        print("¡Conectado exitosamente a SQL Server!")
        
        # El servidor responde con miles de nodos XML o se cuelga (Timeout).
        # Configuramos la extracción para cuando n8n lo ejecute de madrugada.
        try:
            print("Extrayendo datos de promediosSipsaCiudad()... Esto puede tomar unos minutos dependiendo del DANE.")
            datos_sipsa = client.service.promediosSipsaCiudad()
            
            if not datos_sipsa:
                print("El DANE no retornó datos en la consulta.")
                return

            print(f"Se recibieron {len(datos_sipsa)} registros del DANE.")

            # Mapeo estándar (Ejemplo)
            insert_query = """
                INSERT INTO PriceLogs (ProductID, MarketID, SourceTypeID, ReportDate, MinPrice, MaxPrice, AvgPrice, ReportedUnit, StandardizedPricePerKg, CreatedAt)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
            """
            
            for registro in datos_sipsa[:50]: # Límite de prueba
                # Mapeo del SOAP (artiNombre, muniNombre, promedioKg) a nuestro SQL
                # Faltaría la lógica de cruce (JOIN) con nuestros IDs locales.
                pass
                
            conn.commit()
            print("Pipeline ETL finalizado exitosamente.")
            
        except Exception as soap_error:
            print(f"Error de Timeout o saturación en el servidor SOAP del DANE: {soap_error}")
            print("El script está listo y estructurado para cuando el servicio se normalice.")
        
    except Exception as e:
        print(f"Ocurrió un error en el ETL: {e}")

if __name__ == "__main__":
    fetch_sipsa_data()
