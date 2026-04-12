USE AgroForecastDB;
GO

-- 1. Insertar Categorías (Con TOP 1 para seguridad)
IF NOT EXISTS (SELECT TOP 1 1 FROM Categories WHERE CategoryName = 'Verduras y Hortalizas')
    INSERT INTO Categories (CategoryName) VALUES ('Verduras y Hortalizas');
IF NOT EXISTS (SELECT TOP 1 1 FROM Categories WHERE CategoryName = 'Tubérculos')
    INSERT INTO Categories (CategoryName) VALUES ('Tubérculos');
IF NOT EXISTS (SELECT TOP 1 1 FROM Categories WHERE CategoryName = 'Frutas')
    INSERT INTO Categories (CategoryName) VALUES ('Frutas');
IF NOT EXISTS (SELECT TOP 1 1 FROM Categories WHERE CategoryName = 'Granos')
    INSERT INTO Categories (CategoryName) VALUES ('Granos');
GO

-- 2. Insertar Mercados (Centrales de Abasto)
IF NOT EXISTS (SELECT TOP 1 1 FROM Markets WHERE MarketName = 'Corabastos')
    INSERT INTO Markets (MarketName, City, Region) VALUES ('Corabastos', 'Bogotá', 'Cundinamarca');
IF NOT EXISTS (SELECT TOP 1 1 FROM Markets WHERE MarketName = 'Cavasa')
    INSERT INTO Markets (MarketName, City, Region) VALUES ('Cavasa', 'Cali', 'Valle del Cauca');
IF NOT EXISTS (SELECT TOP 1 1 FROM Markets WHERE MarketName = 'Central Mayorista')
    INSERT INTO Markets (MarketName, City, Region) VALUES ('Central Mayorista', 'Medellín', 'Antioquia');
GO

-- 3. Insertar Productos Estándar
IF NOT EXISTS (SELECT TOP 1 1 FROM Products WHERE StandardName = 'Papa Pastusa')
    INSERT INTO Products (CategoryID, StandardName, Description, BaseUnit) 
    VALUES ((SELECT TOP 1 CategoryID FROM Categories WHERE CategoryName = 'Tubérculos'), 'Papa Pastusa', 'Papa de tamaño mediano', 'KG');
    
IF NOT EXISTS (SELECT TOP 1 1 FROM Products WHERE StandardName = 'Cebolla Cabezona Blanca')
    INSERT INTO Products (CategoryID, StandardName, Description, BaseUnit) 
    VALUES ((SELECT TOP 1 CategoryID FROM Categories WHERE CategoryName = 'Verduras y Hortalizas'), 'Cebolla Cabezona Blanca', 'Cebolla de bulbo', 'KG');

IF NOT EXISTS (SELECT TOP 1 1 FROM Products WHERE StandardName = 'Mango Tommy')
    INSERT INTO Products (CategoryID, StandardName, Description, BaseUnit) 
    VALUES ((SELECT TOP 1 CategoryID FROM Categories WHERE CategoryName = 'Frutas'), 'Mango Tommy', 'Mango de mesa', 'KG');

IF NOT EXISTS (SELECT TOP 1 1 FROM Products WHERE StandardName = 'Zanahoria')
    INSERT INTO Products (CategoryID, StandardName, Description, BaseUnit) 
    VALUES ((SELECT TOP 1 CategoryID FROM Categories WHERE CategoryName = 'Verduras y Hortalizas'), 'Zanahoria', 'Zanahoria sabanera', 'KG');
GO

-- 5. Generar Precios Simulados (Últimos 30 días para todos los productos en Corabastos)
DECLARE @MarkID INT = (SELECT TOP 1 MarketID FROM Markets WHERE MarketName = 'Corabastos');
DECLARE @SrcID INT  = (SELECT TOP 1 SourceTypeID FROM SourceTypes WHERE SourceName = 'DANE_SIPSA');

-- Papa Pastusa
DECLARE @ProdPapa INT = (SELECT TOP 1 ProductID FROM Products WHERE StandardName = 'Papa Pastusa');
DELETE FROM PriceLogs WHERE ProductID = @ProdPapa AND MarketID = @MarkID;

-- Cebolla
DECLARE @ProdCebolla INT = (SELECT TOP 1 ProductID FROM Products WHERE StandardName = 'Cebolla Cabezona Blanca');
DELETE FROM PriceLogs WHERE ProductID = @ProdCebolla AND MarketID = @MarkID;

-- Mango
DECLARE @ProdMango INT = (SELECT TOP 1 ProductID FROM Products WHERE StandardName = 'Mango Tommy');
DELETE FROM PriceLogs WHERE ProductID = @ProdMango AND MarketID = @MarkID;

DECLARE @StartDate DATE = DATEADD(day, -30, GETDATE());
DECLARE @EndDate DATE = GETDATE();
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Variables para simular ruido (fluctuación diaria de -200 a +200)
    DECLARE @Ruido DECIMAL(18,2) = (RAND() * 400) - 200;
    
    -- Papa: Alrededor de 1500
    DECLARE @PricePapa DECIMAL(18,2) = 1500 + @Ruido;
    INSERT INTO PriceLogs (ProductID, MarketID, SourceTypeID, ReportDate, MinPrice, MaxPrice, AvgPrice, ReportedUnit, StandardizedPricePerKg, CreatedAt)
    VALUES (@ProdPapa, @MarkID, @SrcID, @CurrentDate, @PricePapa - 50, @PricePapa + 50, @PricePapa, 'KG', @PricePapa, GETDATE());
    
    -- Cebolla: Alrededor de 2100
    DECLARE @PriceCebolla DECIMAL(18,2) = 2100 + @Ruido;
    INSERT INTO PriceLogs (ProductID, MarketID, SourceTypeID, ReportDate, MinPrice, MaxPrice, AvgPrice, ReportedUnit, StandardizedPricePerKg, CreatedAt)
    VALUES (@ProdCebolla, @MarkID, @SrcID, @CurrentDate, @PriceCebolla - 50, @PriceCebolla + 50, @PriceCebolla, 'KG', @PriceCebolla, GETDATE());

    -- Mango: Alrededor de 3500
    DECLARE @PriceMango DECIMAL(18,2) = 3500 + @Ruido;
    INSERT INTO PriceLogs (ProductID, MarketID, SourceTypeID, ReportDate, MinPrice, MaxPrice, AvgPrice, ReportedUnit, StandardizedPricePerKg, CreatedAt)
    VALUES (@ProdMango, @MarkID, @SrcID, @CurrentDate, @PriceMango - 50, @PriceMango + 50, @PriceMango, 'KG', @PriceMango, GETDATE());

    SET @CurrentDate = DATEADD(day, 1, @CurrentDate);
END
GO
