using AgroForecast.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AgroForecast.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AnalyticsController : ControllerBase
{
    private readonly AppDbContext _context;

    public AnalyticsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("trends")]
    public async Task<IActionResult> GetTopPercentageDrops()
    {
        var latestPrices = await _context.PriceLogs
            .Include(p => p.Product)
            .ThenInclude(p => p.Category)
            .Include(p => p.Market)
            .GroupBy(p => new { p.ProductID, p.MarketID })
            .Select(g => g.OrderByDescending(p => p.ReportDate).FirstOrDefault())
            .ToListAsync();

        var oldPrices = await _context.PriceLogs
            .Where(p => p.ReportDate <= DateTime.Now.AddDays(-7))
            .GroupBy(p => new { p.ProductID, p.MarketID })
            .Select(g => g.OrderByDescending(p => p.ReportDate).FirstOrDefault())
            .ToListAsync();

        var trends = new List<object>();

        foreach(var current in latestPrices)
        {
            if (current == null) continue;
            var past = oldPrices.FirstOrDefault(x => x != null && x.ProductID == current.ProductID && x.MarketID == current.MarketID);
            if (past != null)
            {
                var diff = past.AvgPrice - current.AvgPrice;
                var pct = past.AvgPrice > 0 ? (diff / past.AvgPrice) * 100 : 0;
                
                trends.Add(new {
                    ProductName = current.Product.StandardName,
                    Category = current.Product.Category.CategoryName,
                    Market = current.Market.City,
                    CurrentPrice = current.AvgPrice,
                    PastPrice = past.AvgPrice,
                    DropPercentage = pct,
                    ProductId = current.ProductID,
                    MarketId = current.MarketID
                });
            }
        }

        var grouped = trends
            .Cast<dynamic>()
            .GroupBy(t => (string)t.Category)
            .Select(g => new {
                Category = g.Key,
                Top3 = g.OrderByDescending(x => (decimal)x.DropPercentage).Take(3)
            });

        return Ok(grouped);
    }
}
