namespace AgroForecast.Domain.Entities;

public class ProductAlias
{
    public int AliasID { get; set; }
    public string OriginalName { get; set; } = string.Empty;
    public int SourceTypeID { get; set; }
    public int ProductID { get; set; }
    
    // Navigation properties
    public SourceType SourceType { get; set; } = null!;
    public Product Product { get; set; } = null!;
}
