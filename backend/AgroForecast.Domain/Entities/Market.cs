namespace AgroForecast.Domain.Entities;

public class Market
{
    public int MarketID { get; set; }
    public string MarketName { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string? Region { get; set; }
    
    // Navigation properties
    public ICollection<PriceLog> PriceLogs { get; set; } = new List<PriceLog>();
    public ICollection<PriceForecast> PriceForecasts { get; set; } = new List<PriceForecast>();
}
