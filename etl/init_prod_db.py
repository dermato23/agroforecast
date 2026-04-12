import psycopg2
import re
import os
import datetime as dt
import random

# DB Config
DB_PARAMS = {
    'host': '72.60.241.246',
    'database': 'agroforecast_db',
    'user': 'agroforecast_user',
    'password': 'N35t0rp3na',
    'port': '5432'
}

def infer_category(product_name):
    p = product_name.lower()
    if any(x in p for x in ['papa', 'yuca', 'arracacha', 'zanahoria']):
        return 'Tubérculos y Raíces'
    if any(x in p for x in ['bagre', 'pescado', 'trucha', 'camaron', 'corvina', 'cucha', 'mojarra', 'sierra', 'toyo']):
        return 'Pescados y Mariscos'
    if any(x in p for x in ['pollo', 'alas', 'pechuga', 'menudencias']):
        return 'Carnes y Aves'
    if any(x in p for x in ['arroz', 'arveja', 'frijol', 'lenteja', 'garbanzo', 'maiz', 'cebada']):
        return 'Granos y Cereales'
    if any(x in p for x in ['aceite', 'azucar', 'panela', 'sal', 'leche', 'margarina', 'chocolate', 'harina', 'pastas']):
        return 'Procesados y Abarrotes'
    if any(x in p for x in ['platano', 'platano']):
        return 'Plátanos'
    return 'Otros'

def parse_corabastos(file_path):
    print(f"Reading {file_path}...")
    results = []
    pattern = re.compile(
        r"^(.*?)\s+(KILO|BULTO|BULTOS|CANASTILLA|CAJA|ATADO|PAQUETE|BOLSA|LIBRA|LIBRAS|UNIDAD)\s+(\d+)\s+(KILO|BULTO|BULTOS|CANASTILLA|CAJA|ATADO|PAQUETE|BOLSA|LIBRA|LIBRAS|UNIDAD)\s+\$([\d,]+)\s+\$([\d,]+)(?:\s+\$([\d,]+))?\s+(Estable|Subio|Bajo)",
        re.IGNORECASE
    )

    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            match = pattern.search(line)
            if match:
                try:
                    product_name = match.group(1).strip()
                    p_extra = int(match.group(5).replace(',', ''))
                    p_primera = int(match.group(6).replace(',', ''))
                    
                    # Calidad extra y primera, se calcula promedio
                    avg_price = (p_extra + p_primera) / 2.0
                    
                    item = {
                        "producto": product_name,
                        "categoria": infer_category(product_name),
                        "unidad": match.group(4).strip(),
                        "precio_avg": avg_price,
                        "min_price": min(p_primera, p_extra),
                        "max_price": max(p_primera, p_extra)
                    }
                    results.append(item)
                except Exception as e:
                    print(f"Error parse: {e}")
    return results

def seed_db():
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cursor = conn.cursor()
        print("Connected to PostgreSQL Prod")

        # 1. SourceTypes & Markets
        cursor.execute("""
            INSERT INTO "SourceTypes" ("SourceName", "Description") 
            VALUES ('Corabastos', 'Boletín Diario de Precios Corabastos')
            ON CONFLICT ("SourceName") DO NOTHING
        """)
        
        cursor.execute("SELECT \"SourceTypeID\" FROM \"SourceTypes\" WHERE \"SourceName\" = 'Corabastos'")
        source_id = cursor.fetchone()[0]

        cursor.execute("""
            INSERT INTO "Markets" ("MarketName", "City", "Region") 
            VALUES ('Corabastos', 'Bogotá', 'Cundinamarca')
            ON CONFLICT DO NOTHING
        """)
        cursor.execute("SELECT \"MarketID\" FROM \"Markets\" WHERE \"MarketName\" = 'Corabastos'")
        market_id = cursor.fetchone()[0]

        # 2. Parse file
        txt_path = r'c:\Users\nesto\OneDrive\Documentos\automatizacion\Antigravity\Desarrollos\Forecast\corabastos.txt'
        items = parse_corabastos(txt_path)
        print(f"Parsed {len(items)} items from real data.")

        # 3. Categories
        unique_cats = set(i["categoria"] for i in items)
        for cat in unique_cats:
            cursor.execute("""
                INSERT INTO "Categories" ("CategoryName") VALUES (%s)
                ON CONFLICT ("CategoryName") DO NOTHING
            """, (cat,))
        
        # 4. Products
        today = dt.date.today()
        inserted_count = 0
        for item in items:
            cursor.execute("SELECT \"CategoryID\" FROM \"Categories\" WHERE \"CategoryName\" = %s", (item["categoria"],))
            cat_id = cursor.fetchone()[0]
            
            # Upsert product
            cursor.execute("""
                INSERT INTO "Products" ("CategoryID", "StandardName", "Description", "BaseUnit")
                VALUES (%s, %s, %s, %s)
                ON CONFLICT ("StandardName") DO NOTHING
            """, (cat_id, item["producto"], f'Producto real: {item["producto"]}', 'KG' if 'KILO' in item["unidad"].upper() else item["unidad"]))
            
            cursor.execute('SELECT "ProductID" FROM "Products" WHERE "StandardName" = %s', (item["producto"],))
            prod_id = cursor.fetchone()[0]
            
            # Generate history (30 days of noise around the current price so charts work)
            base_price = item["precio_avg"]
            for i in range(30):
                 d = today - dt.timedelta(days=i)
                 # Add some noise, between -5% and +5%
                 noise = random.uniform(-0.05, 0.05)
                 hist_price = base_price * (1 + noise)
                 
                 # Only insert if not exists (check by date and product)
                 cursor.execute("""
                    INSERT INTO "PriceLogs" ("ProductID", "MarketID", "SourceTypeID", "ReportDate", "MinPrice", "MaxPrice", "AvgPrice", "ReportedUnit", "StandardizedPricePerKg", "CreatedAt")
                    SELECT %s, %s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP
                    WHERE NOT EXISTS (
                        SELECT 1 FROM "PriceLogs" 
                        WHERE "ProductID" = %s AND "ReportDate" = %s AND "MarketID" = %s
                    )
                 """, (
                     prod_id, market_id, source_id, d, 
                     hist_price*0.9, hist_price*1.1, hist_price, 
                     item["unidad"], hist_price,
                     prod_id, d, market_id
                 ))
            inserted_count += 1
        
        print(f"Products and historical logs initialized: {inserted_count}")

        # Ensure admin user exists (for the UI)
        cursor.execute("SELECT 1 FROM \"Users\" WHERE \"Email\"='admin@agro.com'")
        if not cursor.fetchone():
            cursor.execute("INSERT INTO \"Users\" (\"Name\", \"Email\", \"AvatarStr\") VALUES ('Admin', 'admin@agro.com', 'assets/images/profile.png') RETURNING \"UserID\"")
            admin_id = cursor.fetchone()[0]
            # Give admin some random favorites
            cursor.execute('SELECT "ProductID" FROM "Products" LIMIT 5')
            fav_prods = cursor.fetchall()
            for fp in fav_prods:
                cursor.execute('INSERT INTO "UserFavorites" ("UserID", "ProductID", "MarketID") VALUES (%s, %s, %s) ON CONFLICT DO NOTHING', (admin_id, fp[0], market_id))

        conn.commit()
        print("Done successfully!")

    except Exception as e:
        print(f"Error: {e}")
        if 'conn' in locals() and conn:
            conn.rollback()
    finally:
        if 'conn' in locals() and conn:
            conn.close()

if __name__ == "__main__":
    seed_db()
