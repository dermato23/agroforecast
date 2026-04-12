using AgroForecast.Application.Interfaces;
using AgroForecast.Domain.Entities;
using AgroForecast.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AgroForecast.Infrastructure.Repositories;

public class MarketRepository : IMarketRepository
{
    private readonly AppDbContext _context;

    public MarketRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Market>> GetAllMarketsAsync()
    {
        return await _context.Markets
            .OrderBy(m => m.City)
            .ThenBy(m => m.MarketName)
            .ToListAsync();
    }

    public async Task<Market?> GetByIdAsync(int id)
    {
        return await _context.Markets.FindAsync(id);
    }
}
