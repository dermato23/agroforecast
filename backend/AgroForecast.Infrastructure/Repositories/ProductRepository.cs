using AgroForecast.Application.Interfaces;
using AgroForecast.Domain.Entities;
using AgroForecast.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AgroForecast.Infrastructure.Repositories;

public class ProductRepository : IProductRepository
{
    private readonly AppDbContext _context;

    public ProductRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        return await _context.Products
            .Include(p => p.Category)
            .OrderBy(p => p.StandardName)
            .ToListAsync();
    }
}
