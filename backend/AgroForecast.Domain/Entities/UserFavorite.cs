namespace AgroForecast.Domain.Entities;

public class UserFavorite
{
    public int FavoriteID { get; set; }
    public int UserID { get; set; }
    public int ProductID { get; set; }
    public int MarketID { get; set; }

    public User User { get; set; } = null!;
    public Product Product { get; set; } = null!;
    public Market Market { get; set; } = null!;
}
