-- =========================================================================================
-- Base de Datos: AgroForecastDB
-- Descripción: Esquema inicial para almacenar histórico de precios y predicciones (Forecast)
-- =========================================================================================

-- CREATE DATABASE AgroForecastDB;
-- GO
-- USE AgroForecastDB;
-- GO

-- 1. Catálogo de Fuentes de Información (Ej: DANE SIPSA, Corabastos, etc.)
CREATE TABLE SourceTypes (
    SourceTypeID INT IDENTITY(1,1) PRIMARY KEY,
    SourceName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);

-- 2. Mercados o Centrales de Abasto (Ej: Corabastos Bogotá, Cavasa Cali)
CREATE TABLE Markets (
    MarketID INT IDENTITY(1,1) PRIMARY KEY,
    MarketName NVARCHAR(150) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Region NVARCHAR(100) NULL
);

-- 3. Categorías de Productos (Ej: Tubérculos, Frutas, Verduras)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE
);

-- 4. Catálogo Estandarizado de Productos
-- Nota: La estandarización es clave porque Corabastos y DANE pueden llamar al 
-- mismo producto de manera distinta (ej. "Papa parda" vs "Papa pastusa parda").
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    StandardName NVARCHAR(150) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    BaseUnit NVARCHAR(50) NOT NULL DEFAULT 'KG', -- Unidad de medida estandarizada
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 5. Tabla de Equivalencias (Product Mapping)
-- Mapea los nombres de origen (DANE, Corabastos) al producto estandarizado.
CREATE TABLE ProductAliases (
    AliasID INT IDENTITY(1,1) PRIMARY KEY,
    OriginalName NVARCHAR(150) NOT NULL,
    SourceTypeID INT NOT NULL,
    ProductID INT NOT NULL,
    CONSTRAINT FK_Aliases_Sources FOREIGN KEY (SourceTypeID) REFERENCES SourceTypes(SourceTypeID),
    CONSTRAINT FK_Aliases_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT UQ_Alias_Source UNIQUE (OriginalName, SourceTypeID)
);

-- 6. Histórico de Precios (Ingesta de Datos Diaria/Semanal)
CREATE TABLE PriceLogs (
    PriceLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    MarketID INT NOT NULL,
    SourceTypeID INT NOT NULL,
    ReportDate DATE NOT NULL,
    MinPrice DECIMAL(18,2) NULL,
    MaxPrice DECIMAL(18,2) NULL,
    AvgPrice DECIMAL(18,2) NOT NULL,
    ReportedUnit NVARCHAR(50) NOT NULL, -- Unidad original (Ej: Bulto 50Kg)
    StandardizedPricePerKg DECIMAL(18,2) NOT NULL, -- Precio limpio y calculado por KG
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Prices_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_Prices_Markets FOREIGN KEY (MarketID) REFERENCES Markets(MarketID),
    CONSTRAINT FK_Prices_Sources FOREIGN KEY (SourceTypeID) REFERENCES SourceTypes(SourceTypeID)
);
-- Índice para búsquedas rápidas por fecha y producto
CREATE INDEX IX_PriceLogs_Product_Date ON PriceLogs(ProductID, ReportDate);

-- 7. Tabla de Predicciones y Semáforo (Output del Modelo de IA)
CREATE TABLE PriceForecasts (
    ForecastID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    MarketID INT NOT NULL,
    ForecastDate DATE NOT NULL,          -- Fecha para la cual es la predicción
    PredictedAvgPrice DECIMAL(18,2) NOT NULL,
    ConfidenceScore DECIMAL(5,2) NULL,   -- Nivel de confianza del modelo (%)
    Recommendation NVARCHAR(20) NOT NULL CHECK (Recommendation IN ('Comprar', 'Mantener', 'Esperar')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Forecasts_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_Forecasts_Markets FOREIGN KEY (MarketID) REFERENCES Markets(MarketID)
);
-- Índice para búsquedas del dashboard de la app
CREATE INDEX IX_Forecasts_Product_Date ON PriceForecasts(ProductID, ForecastDate);

-- =========================================================================================
-- Datos Iniciales Básicos
-- =========================================================================================
INSERT INTO SourceTypes (SourceName, Description) VALUES 
('Corabastos', 'Boletín Diario de Precios Corabastos'),
('DANE_SIPSA', 'Web Service SOAP SIPSA - Ministerio de Agricultura');
GO
