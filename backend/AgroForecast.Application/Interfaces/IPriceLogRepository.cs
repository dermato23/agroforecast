using AgroForecast.Domain.Entities;

namespace AgroForecast.Application.Interfaces;

public interface IPriceLogRepository
{
    Task<IEnumerable<PriceLog>> GetRecentPriceLogsAsync(int productId, int? marketId = null, int limit = 30);
    Task<PriceLog?> GetLatestPriceLogAsync(int productId, int marketId);
}
