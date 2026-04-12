using AgroForecast.Application.DTOs;
using AgroForecast.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AgroForecast.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MarketsController : ControllerBase
{
    private readonly IMarketRepository _repository;

    public MarketsController(IMarketRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MarketDto>>> GetAllMarkets()
    {
        var markets = await _repository.GetAllMarketsAsync();
        
        var dto = markets.Select(m => new MarketDto
        {
            Id = m.MarketID,
            Name = m.MarketName,
            City = m.City
        });

        return Ok(dto);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<MarketDto>> GetMarket(int id)
    {
        var market = await _repository.GetByIdAsync(id);

        if (market == null)
        {
            return NotFound();
        }

        return Ok(new MarketDto
        {
            Id = market.MarketID,
            Name = market.MarketName,
            City = market.City
        });
    }
}
