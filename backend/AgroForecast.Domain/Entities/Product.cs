namespace AgroForecast.Domain.Entities;

public class Product
{
    public int ProductID { get; set; }
    public int CategoryID { get; set; }
    public string StandardName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string BaseUnit { get; set; } = "KG";
    
    // Navigation properties
    public Category Category { get; set; } = null!;
    public ICollection<ProductAlias> ProductAliases { get; set; } = new List<ProductAlias>();
    public ICollection<PriceLog> PriceLogs { get; set; } = new List<PriceLog>();
    public ICollection<PriceForecast> PriceForecasts { get; set; } = new List<PriceForecast>();
}
