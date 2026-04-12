using AgroForecast.Application.Interfaces;
using AgroForecast.Domain.Entities;
using AgroForecast.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AgroForecast.Infrastructure.Repositories;

public class PriceLogRepository : IPriceLogRepository
{
    private readonly AppDbContext _context;

    public PriceLogRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<PriceLog>> GetRecentPriceLogsAsync(int productId, int? marketId = null, int limit = 30)
    {
        var query = _context.PriceLogs
            .Include(p => p.Product)
            .Include(p => p.Market)
            .Include(p => p.SourceType)
            .Where(p => p.ProductID == productId);

        if (marketId.HasValue)
        {
            query = query.Where(p => p.MarketID == marketId.Value);
        }

        return await query
            .OrderByDescending(p => p.ReportDate)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<PriceLog?> GetLatestPriceLogAsync(int productId, int marketId)
    {
        return await _context.PriceLogs
            .Include(p => p.Product)
            .Include(p => p.Market)
            .Include(p => p.SourceType)
            .Where(p => p.ProductID == productId && p.MarketID == marketId)
            .OrderByDescending(p => p.ReportDate)
            .FirstOrDefaultAsync();
    }
}
