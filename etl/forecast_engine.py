import pyodbc
import pandas as pd
import numpy as np

def connect_db():
    try:
        # Usamos el punto en lugar de localhost para la instancia por defecto O SQLEXPRESS
        # Dado que probamos que funciona con NESTORZ13\SQLEXPRESS, usémosla directamente.
        conn_str = (
            r'Driver={ODBC Driver 17 for SQL Server};'
            r'Server=NESTORZ13\SQLEXPRESS;'
            r'Database=AgroForecastDB;'
            r'Trusted_Connection=yes;'
        )
        return pyodbc.connect(conn_str)
    except Exception as e:
        print(f"Error conectando a BD: {e}")
        return None

def generate_forecasts():
    conn = connect_db()
    if not conn:
        return
        
    cursor = conn.cursor()
    
    # 1. Leer todo el historico usando Pandas
    print("Recopilando histórico de precios...")
    query = """
        SELECT PriceLogID, ProductID, MarketID, ReportDate, AvgPrice 
        FROM PriceLogs 
        ORDER BY ProductID, MarketID, ReportDate ASC
    """
    df = pd.read_sql(query, conn)
    
    if df.empty:
        print("No hay datos históricos para analizar.")
        return

    # 2. Calcular Medias Móviles y Semáforo por Producto y Mercado
    print("Calculando tendencias y Modelo de Semáforo...")
    
    forecasts_to_insert = []
    
    # Agrupamos por producto y mercado para no mezclar precios de papa con cebolla
    for (product_id, market_id), group in df.groupby(['ProductID', 'MarketID']):
        # Asegurar orden cronológico
        group = group.sort_values(by='ReportDate')
        
        # Calcular media móvil de 7 días y la desviación estándar
        group['SMA_7'] = group['AvgPrice'].rolling(window=7, min_periods=1).mean()
        group['STD_7'] = group['AvgPrice'].rolling(window=7, min_periods=1).std().fillna(0)
        
        # Nos interesa predecir/recomendar basándonos en el último día registrado
        last_record = group.iloc[-1]
        
        current_price = last_record['AvgPrice']
        avg_price_7d = last_record['SMA_7']
        std_dev = last_record['STD_7']
        
        # --- Lógica del Semáforo ---
        # Si el precio actual está muy por encima del promedio reciente (Promedio + 1 Desviación) -> Esperar (Rojo)
        # Si está muy por debajo o estable bajo el promedio -> Comprar (Verde)
        # Si está en el rango normal -> Mantener (Amarillo)
        
        if current_price > (avg_price_7d + std_dev) and std_dev > 0:
            recommendation = "Esperar"
            confidence = 85.0
        elif current_price <= avg_price_7d:
            recommendation = "Comprar"
            confidence = 90.0
        else:
            recommendation = "Mantener"
            confidence = 75.0
            
        print(f"Producto {product_id} | Precio Hoy: ${current_price:.2f} | Promedio 7D: ${avg_price_7d:.2f} | Info: {recommendation}")
        
        # Fecha del "mañana" o la proxima recomendacion
        forecast_date = last_record['ReportDate'] + pd.Timedelta(days=1)
        
        # Estimamos que el precio tenderá a regresar a la media móvil (Mean Reversion simple)
        predicted_price = avg_price_7d 
        
        forecasts_to_insert.append((
            product_id, 
            market_id, 
            forecast_date.strftime('%Y-%m-%d'), 
            float(predicted_price), 
            float(confidence), 
            recommendation
        ))

    # 3. Guardar las predicciones en la base de datos
    print("Guardando predicciones en SQL Server...")
    for f in forecasts_to_insert:
        # Borramos predicciones viejas para esa fecha/producto para que el script no duplique
        cursor.execute("DELETE FROM PriceForecasts WHERE ProductID=? AND MarketID=? AND ForecastDate=?", f[0], f[1], f[2])
        
        cursor.execute("""
            INSERT INTO PriceForecasts (ProductID, MarketID, ForecastDate, PredictedAvgPrice, ConfidenceScore, Recommendation, CreatedAt)
            VALUES (?, ?, ?, ?, ?, ?, GETDATE())
        """, f)
    
    conn.commit()
    cursor.close()
    conn.close()
    print("¡Modelo ejecutado correctamente y semáforos actualizados!")

if __name__ == "__main__":
    generate_forecasts()
