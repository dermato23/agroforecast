import psycopg2

try:
    conn = psycopg2.connect(
        host='72.60.241.246',
        database='agroforecast_db',
        user='agroforecast_user',
        password='N35t0rp3na'
    )
    cur = conn.cursor()
    cur.execute('''
    SELECT
      p."StandardName",
      MIN(pl."StandardizedPricePerKg") as min_price,
      MAX(pl."StandardizedPricePerKg") as max_price,
      MAX(pl."StandardizedPricePerKg") - MIN(pl."StandardizedPricePerKg") as variation
    FROM "PriceLogs" pl
    JOIN "Products" p ON pl."ProductID" = p."ProductID"
    GROUP BY p."StandardName"
    HAVING MIN(pl."StandardizedPricePerKg") <> MAX(pl."StandardizedPricePerKg")
    ORDER BY variation DESC;
    ''')
    rows = cur.fetchall()
    
    if rows:
        print("\n--- PRODUCTOS CON VARIACIONES ---")
        print("{:<30} | {:<10} | {:<10} | {:<10}".format("Producto", "Minimo", "Maximo", "Variacion"))
        print("-" * 65)
        for row in rows:
            print("{:<30} | ${:<9.0f} | ${:<9.0f} | ${:<9.0f}".format(row[0][:30], row[1], row[2], row[3]))
    else:
        print("\nNo hay productos con variaciones de precio en estos días. Todos los precios registrados se han mantenido idénticos cada día.")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
