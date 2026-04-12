using AgroForecast.Domain.Entities;

namespace AgroForecast.Application.Interfaces;

public interface IMarketRepository
{
    Task<IEnumerable<Market>> GetAllMarketsAsync();
    Task<Market?> GetByIdAsync(int id);
}
