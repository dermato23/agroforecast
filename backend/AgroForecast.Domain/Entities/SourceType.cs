namespace AgroForecast.Domain.Entities;

public class SourceType
{
    public int SourceTypeID { get; set; }
    public string SourceName { get; set; } = string.Empty;
    public string? Description { get; set; }
    
    // Navigation properties
    public ICollection<ProductAlias> ProductAliases { get; set; } = new List<ProductAlias>();
    public ICollection<PriceLog> PriceLogs { get; set; } = new List<PriceLog>();
}
