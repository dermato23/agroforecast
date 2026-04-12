namespace AgroForecast.Domain.Entities;

public class Category
{
    public int CategoryID { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    
    // Navigation properties
    public ICollection<Product> Products { get; set; } = new List<Product>();
}
