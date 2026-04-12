using AgroForecast.Infrastructure.Data;
using AgroForecast.Domain.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AgroForecast.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProfileController : ControllerBase
{
    private readonly AppDbContext _context;

    public ProfileController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("{userId}")]
    public async Task<IActionResult> GetProfileAndSavings(int userId)
    {
        var user = await _context.Users
            .Include(u => u.SavingsLogs)
            .FirstOrDefaultAsync(u => u.UserID == userId);

        if (user == null) return NotFound();

        var totalSaved = user.SavingsLogs.Sum(s => s.SavedAmount);

        return Ok(new
        {
            user.Name,
            user.Email,
            user.AvatarStr,
            TotalSaved = totalSaved,
            Logs = user.SavingsLogs.OrderByDescending(s => s.Date).Select(s => new {
                s.Date,
                s.SavedAmount,
                s.KilosBought,
                s.ProductID
            })
        });
    }

    [HttpPost("{userId}/savings")]
    public async Task<IActionResult> AddSaving(int userId, [FromBody] SavingDto dto)
    {
        var saving = new SavingsLog {
            UserID = userId,
            ProductID = dto.ProductId,
            Date = DateTime.Now,
            SavedAmount = dto.SavedAmount,
            KilosBought = dto.KilosBought
        };
        _context.SavingsLogs.Add(saving);
        await _context.SaveChangesAsync();
        return Ok(saving);
    }
}

public class SavingDto {
    public int ProductId { get; set; }
    public decimal SavedAmount { get; set; }
    public decimal KilosBought { get; set; }
}
