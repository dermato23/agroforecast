using System;

namespace AgroForecast.Domain.Entities;

public class SavingsLog
{
    public int SavingsLogID { get; set; }
    public int UserID { get; set; }
    public int ProductID { get; set; }
    public DateTime Date { get; set; }
    public decimal SavedAmount { get; set; }
    public decimal KilosBought { get; set; }

    public User User { get; set; } = null!;
    public Product Product { get; set; } = null!;
}
