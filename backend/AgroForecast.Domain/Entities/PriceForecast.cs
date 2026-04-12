namespace AgroForecast.Domain.Entities;

public class PriceForecast
{
    public long ForecastID { get; set; }
    public int ProductID { get; set; }
    public int MarketID { get; set; }
    public DateTime ForecastDate { get; set; }
    public decimal PredictedAvgPrice { get; set; }
    public decimal? ConfidenceScore { get; set; }
    public string Recommendation { get; set; } = string.Empty; // Comprar, Mantener, Esperar
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public Product Product { get; set; } = null!;
    public Market Market { get; set; } = null!;
}
