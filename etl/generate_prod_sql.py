import re
import datetime as dt
import random
import os

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
    if any(x in p for x in ['platano']):
        return 'Plátanos'
    return 'Otros'

def parse_corabastos(file_path):
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
                    avg_price = (p_extra + p_primera) / 2.0
                    results.append({
                        "producto": product_name,
                        "categoria": infer_category(product_name),
                        "unidad": match.group(4).strip(),
                        "precio_avg": avg_price,
                        "min_price": min(p_primera, p_extra),
                        "max_price": max(p_primera, p_extra)
                    })
                except: pass
    return results

def generate_sql():
    txt_path = r'c:\Users\nesto\OneDrive\Documentos\automatizacion\Antigravity\Desarrollos\Forecast\corabastos.txt'
    out_path = r'c:\Users\nesto\OneDrive\Documentos\automatizacion\Antigravity\Desarrollos\Forecast\etl\seed_prod.sql'
    
    items = parse_corabastos(txt_path)
    
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('BEGIN;\n')
        
        # 1. Sources & Markets
        f.write('''
INSERT INTO "SourceTypes" ("SourceName", "Description") VALUES ('Corabastos', 'Boletín Diario de Precios Corabastos') ON CONFLICT ("SourceName") DO NOTHING;
INSERT INTO "Markets" ("MarketName", "City", "Region") VALUES ('Corabastos', 'Bogotá', 'Cundinamarca') ON CONFLICT DO NOTHING;
''')

        # 2. Categories
        unique_cats = set(i["categoria"] for i in items)
        for cat in unique_cats:
            f.write(f"INSERT INTO \"Categories\" (\"CategoryName\") VALUES ('{cat}') ON CONFLICT (\"CategoryName\") DO NOTHING;\n")
        
        # 3. Products
        for item in items:
            cat_name = item["categoria"].replace("'", "''")
            prod_name = item["producto"].replace("'", "''")
            unit = 'KG' if 'KILO' in item["unidad"].upper() else item["unidad"].replace("'", "''")
            
            f.write(f"""
INSERT INTO "Products" ("CategoryID", "StandardName", "Description", "BaseUnit")
SELECT "CategoryID", '{prod_name}', 'Producto real: {prod_name}', '{unit}'
FROM "Categories" WHERE "CategoryName" = '{cat_name}'
ON CONFLICT ("StandardName") DO NOTHING;
""")
        
        # 4. History (last 30 days)
        today = dt.date.today()
        for item in items:
            prod_name = item["producto"].replace("'", "''")
            unit = 'KG' if 'KILO' in item["unidad"].upper() else item["unidad"].replace("'", "''")
            base_price = item["precio_avg"]
            
            for i in range(30):
                d = today - dt.timedelta(days=i)
                noise = random.uniform(-0.05, 0.05)
                hist_price = round(base_price * (1 + noise), 2)
                
                f.write(f"""
INSERT INTO "PriceLogs" ("ProductID", "MarketID", "SourceTypeID", "ReportDate", "MinPrice", "MaxPrice", "AvgPrice", "ReportedUnit", "StandardizedPricePerKg", "CreatedAt")
SELECT P."ProductID", M."MarketID", S."SourceTypeID", '{d.strftime("%Y-%m-%d")}', {hist_price*0.9}, {hist_price*1.1}, {hist_price}, '{unit}', {hist_price}, CURRENT_TIMESTAMP
FROM "Products" P, "Markets" M, "SourceTypes" S
WHERE P."StandardName" = '{prod_name}' AND M."MarketName" = 'Corabastos' AND S."SourceName" = 'Corabastos'
AND NOT EXISTS (
    SELECT 1 FROM "PriceLogs" PL 
    WHERE PL."ProductID" = P."ProductID" AND PL."ReportDate" = '{d.strftime("%Y-%m-%d")}' AND PL."MarketID" = M."MarketID"
);
""")

        # 5. User
        f.write('''
DO $$
DECLARE
    new_user_id INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "Users" WHERE "Email"='admin@agro.com') THEN
        INSERT INTO "Users" ("Name", "Email", "AvatarStr") VALUES ('Admin', 'admin@agro.com', 'assets/images/profile.png') RETURNING "UserID" INTO new_user_id;
        
        INSERT INTO "UserFavorites" ("UserID", "ProductID", "MarketID")
        SELECT new_user_id, "ProductID", (SELECT "MarketID" FROM "Markets" WHERE "MarketName" = 'Corabastos' LIMIT 1)
        FROM "Products" LIMIT 5;
    END IF;
END $$;
''')

        f.write('COMMIT;\n')
        
    print(f"SQL file generated at {out_path} with {len(items)} products.")

if __name__ == '__main__':
    generate_sql()
