using AgroForecast.Application.DTOs;
using AgroForecast.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AgroForecast.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PricesController : ControllerBase
{
    private readonly IPriceLogRepository _repository;

    public PricesController(IPriceLogRepository repository)
    {
        _repository = repository;
    }

    [HttpGet("product/{productId}")]
    public async Task<ActionResult<IEnumerable<PriceLogDto>>> GetRecentPrices(int productId, [FromQuery] int? marketId)
    {
        // Traemos las entidades del repositorio (Base de Datos)
        var logs = await _repository.GetRecentPriceLogsAsync(productId, marketId);

        if (!logs.Any())
        {
            return NotFound(new { message = $"No se encontraron precios para el producto {productId}" });
        }

        // Mapeamos a DTO (Data Transfer Object) para no enviar clases de Base de datos puras a internet
        var dto = logs.Select(l => new PriceLogDto
        {
            Id = l.PriceLogID,
            ProductName = l.Product?.StandardName ?? "Desconocido",
            MarketName = l.Market?.MarketName ?? "Desconocido",
            SourceName = l.SourceType?.SourceName ?? "Desconocido",
            Date = l.ReportDate,
            AveragePricePerKg = l.StandardizedPricePerKg,
            MinPrice = l.MinPrice,
            MaxPrice = l.MaxPrice,
            OriginalUnit = l.ReportedUnit
        });

        return Ok(dto);
    }

    [HttpGet("product/{productId}/market/{marketId}/latest")]
    public async Task<ActionResult<PriceLogDto>> GetLatestPrice(int productId, int marketId)
    {
        var log = await _repository.GetLatestPriceLogAsync(productId, marketId);

        if (log == null)
        {
            return NotFound();
        }

        return Ok(new PriceLogDto
        {
            Id = log.PriceLogID,
            Date = log.ReportDate,
            AveragePricePerKg = log.StandardizedPricePerKg
        });
    }
}
