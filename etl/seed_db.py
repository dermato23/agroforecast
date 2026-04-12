import pyodbc
import random
import datetime as dt

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

def seed_database():
    conn = conectar_bd()
    if not conn:
        return
        
    cursor = conn.cursor()
    print("Conectado a la Base de Datos. Iniciando Seed...")

    try:
        # 0. Limpieza Profunda
        print("Limpiando datos y reseteando IDs...")
        cursor.execute("IF OBJECT_ID('SavingsLogs', 'U') IS NOT NULL DROP TABLE SavingsLogs")
        cursor.execute("IF OBJECT_ID('UserFavorites', 'U') IS NOT NULL DROP TABLE UserFavorites")
        cursor.execute("IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users")
        
        cursor.execute("DELETE FROM PriceForecasts")
        cursor.execute("DELETE FROM PriceLogs")
        cursor.execute("DELETE FROM ProductAliases")
        cursor.execute("DELETE FROM Products")
        cursor.execute("DELETE FROM Markets")
        cursor.execute("DELETE FROM Categories")
        
        # Resetear Identity seeds
        cursor.execute("IF EXISTS (SELECT * FROM sys.tables WHERE name='Products') DBCC CHECKIDENT ('Products', RESEED, 0)")
        cursor.execute("IF EXISTS (SELECT * FROM sys.tables WHERE name='Markets') DBCC CHECKIDENT ('Markets', RESEED, 0)")
        cursor.execute("IF EXISTS (SELECT * FROM sys.tables WHERE name='Categories') DBCC CHECKIDENT ('Categories', RESEED, 0)")
        cursor.execute("IF EXISTS (SELECT * FROM sys.tables WHERE name='PriceForecasts') DBCC CHECKIDENT ('PriceForecasts', RESEED, 0)")
        cursor.execute("IF EXISTS (SELECT * FROM sys.tables WHERE name='PriceLogs') DBCC CHECKIDENT ('PriceLogs', RESEED, 0)")
        
        conn.commit()

        # 1. Insertar Categorías
        print("Insertando Categorías...")
        categories = ['Tubérculos', 'Frutas', 'Verduras y Hortalizas', 'Granos']
        for cat in categories:
            cursor.execute("INSERT INTO Categories (CategoryName) VALUES (?)", cat)
        
        cursor.execute("SELECT CategoryID, CategoryName FROM Categories")
        cat_map = {name: id for id, name in cursor.fetchall()}

        # 2. Insertar Mercados
        print("Insertando Mercados...")
        mercados = [
            ('Corabastos', 'Bogotá', 'Cundinamarca'),
            ('Cavasa', 'Cali', 'Valle del Cauca'),
            ('Central Mayorista', 'Medellín', 'Antioquia')
        ]
        for nombre, ciudad, region in mercados:
            cursor.execute("INSERT INTO Markets (MarketName, City, Region) VALUES (?, ?, ?)", nombre, ciudad, region)

        # 3. Insertar Productos
        print("Insertando Productos Base...")
        productos = [
            ('Tubérculos', 'Papa Pastusa', 'Papa de tamaño mediano', 'KG'),
            ('Verduras y Hortalizas', 'Cebolla Cabezona Blanca', 'Cebolla de bulbo', 'KG'),
            ('Frutas', 'Mango Tommy', 'Mango de mesa', 'KG'),
            ('Verduras y Hortalizas', 'Zanahoria', 'Zanahoria sabanera', 'KG')
        ]
        for cat_name, nombre, desc, unit in productos:
            cat_id = cat_map.get(cat_name, 1)
            cursor.execute("INSERT INTO Products (CategoryID, StandardName, Description, BaseUnit) VALUES (?, ?, ?, ?)", cat_id, nombre, desc, unit)

        # 4. Fuente de Datos
        cursor.execute("IF NOT EXISTS (SELECT * FROM SourceTypes WHERE SourceTypeID=1) INSERT INTO SourceTypes (SourceTypeID, SourceName) VALUES (1, 'SIPSA/DANE')")

        # 5. Generar Precios
        print("Generando Histórico Multi-Ciudad (30 días)...")
        cursor.execute("SELECT MarketID, City FROM Markets")
        markets_db = cursor.fetchall()
        
        cursor.execute("SELECT ProductID, StandardName FROM Products")
        prods_db = cursor.fetchall()
        
        today = dt.date.today()
        precios_base_map = {
            'Papa Pastusa': 1500,
            'Cebolla Cabezona Blanca': 2400,
            'Mango Tommy': 4200,
            'Zanahoria': 1800
        }
        
        city_offsets = {
            'Bogotá': 0,
            'Cali': 150,
            'Medellín': 250
        }

        for m_id, city in markets_db:
            offset = city_offsets.get(city, 0)
            print(f"  -> {city} (Market ID: {m_id})...")
            for i in range(30):
                d = today - dt.timedelta(days=i)
                for p_id, p_name in prods_db:
                    base_price = precios_base_map.get(p_name, 2000)
                    variacion = random.uniform(-150, 150)
                    precio_avg = max(500.0, float(base_price + offset + variacion))
                    
                    cursor.execute("""
                        INSERT INTO PriceLogs (ProductID, MarketID, SourceTypeID, ReportDate, MinPrice, MaxPrice, AvgPrice, ReportedUnit, StandardizedPricePerKg, CreatedAt)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
                    """, (p_id, m_id, 1, d, precio_avg-100, precio_avg+100, precio_avg, 'KG', precio_avg))

        # 6. Nuevas estructuras para Usuarios, Favoritos y Ahorros
        print("Creando y poblando tablas de Usuario...")
        cursor.execute("""
            CREATE TABLE Users (
                UserID INT IDENTITY(1,1) PRIMARY KEY,
                Name NVARCHAR(150),
                Email NVARCHAR(150) UNIQUE,
                AvatarStr NVARCHAR(255)
            )
        """)
        cursor.execute("""
            CREATE TABLE UserFavorites (
                FavoriteID INT IDENTITY(1,1) PRIMARY KEY,
                UserID INT,
                ProductID INT,
                MarketID INT,
                CONSTRAINT UQ_Fav UNIQUE(UserID, ProductID, MarketID)
            )
        """)
        cursor.execute("""
            CREATE TABLE SavingsLogs (
                SavingsLogID INT IDENTITY(1,1) PRIMARY KEY,
                UserID INT,
                ProductID INT,
                Date DATETIME,
                SavedAmount DECIMAL(18,2),
                KilosBought DECIMAL(18,2)
            )
        """)
        
        # Insertar Usuario Admin y algunos ahorros iniciales para que puedan verse en el Perfil
        cursor.execute("INSERT INTO Users (Name, Email, AvatarStr) VALUES ('Admin', 'admin@agro.com', 'assets/images/profile.png')")
        cursor.execute("SELECT UserID FROM Users WHERE Email='admin@agro.com'")
        admin_id = cursor.fetchone()[0]

        cursor.execute("INSERT INTO SavingsLogs (UserID, ProductID, Date, SavedAmount, KilosBought) VALUES (?, ?, GETDATE(), ?, ?)", (admin_id, 1, 15000, 30))
        cursor.execute("INSERT INTO SavingsLogs (UserID, ProductID, Date, SavedAmount, KilosBought) VALUES (?, ?, GETDATE()-1, ?, ?)", (admin_id, 2, 4500, 10))
        
        # Un favorito base
        cursor.execute("INSERT INTO UserFavorites (UserID, ProductID, MarketID) VALUES (?, 1, 1)", (admin_id,))

        conn.commit()
        print("¡Seed completado con éxito!")
        
    except Exception as e:
        print(f"Error durante el seed: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    seed_database()
