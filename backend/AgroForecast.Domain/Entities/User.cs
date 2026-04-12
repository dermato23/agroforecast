namespace AgroForecast.Domain.Entities;

public class User
{
    public int UserID { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string AvatarStr { get; set; } = string.Empty;

    public ICollection<UserFavorite> UserFavorites { get; set; } = new List<UserFavorite>();
    public ICollection<SavingsLog> SavingsLogs { get; set; } = new List<SavingsLog>();
}
