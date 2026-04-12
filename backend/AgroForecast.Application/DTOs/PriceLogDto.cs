namespace AgroForecast.Application.DTOs;

public class PriceLogDto
{
    public long Id { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string MarketName { get; set; } = string.Empty;
    public string SourceName { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public decimal AveragePricePerKg { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public string OriginalUnit { get; set; } = string.Empty;
}
