using AgroForecast.Infrastructure.Data;
using AgroForecast.Domain.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AgroForecast.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FavoritesController : ControllerBase
{
    private readonly AppDbContext _context;

    public FavoritesController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("{userId}")]
    public async Task<IActionResult> GetFavorites(int userId)
    {
        var favs = await _context.UserFavorites
            .Include(f => f.Product)
            .Include(f => f.Market)
            .Where(f => f.UserID == userId)
            .Select(f => new {
                f.FavoriteID,
                f.ProductID,
                ProductName = f.Product.StandardName,
                f.MarketID,
                MarketCity = f.Market.City
            }).ToListAsync();

        return Ok(favs);
    }

    [HttpPost("{userId}")]
    public async Task<IActionResult> AddFavorite(int userId, [FromBody] FavDto dto)
    {
        if (await _context.UserFavorites.AnyAsync(f => f.UserID == userId && f.ProductID == dto.ProductId && f.MarketID == dto.MarketId))
            return BadRequest("Already favorite");

        var fav = new UserFavorite { UserID = userId, ProductID = dto.ProductId, MarketID = dto.MarketId };
        _context.UserFavorites.Add(fav);
        await _context.SaveChangesAsync();
        return Ok(fav);
    }

    [HttpDelete("{userId}/{favId}")]
    public async Task<IActionResult> RemoveFavorite(int userId, int favId)
    {
        var fav = await _context.UserFavorites.FirstOrDefaultAsync(f => f.FavoriteID == favId && f.UserID == userId);
        if (fav != null)
        {
            _context.UserFavorites.Remove(fav);
            await _context.SaveChangesAsync();
        }
        return Ok();
    }
}

public class FavDto {
    public int ProductId { get; set; }
    public int MarketId { get; set; }
}
