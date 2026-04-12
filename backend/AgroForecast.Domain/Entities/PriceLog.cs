namespace AgroForecast.Domain.Entities;

public class PriceLog
{
    public long PriceLogID { get; set; }
    public int ProductID { get; set; }
    public int MarketID { get; set; }
    public int SourceTypeID { get; set; }
    public DateTime ReportDate { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public decimal AvgPrice { get; set; }
    public string ReportedUnit { get; set; } = string.Empty;
    public decimal StandardizedPricePerKg { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public Product Product { get; set; } = null!;
    public Market Market { get; set; } = null!;
    public SourceType SourceType { get; set; } = null!;
}
