using AgroForecast.Domain.Entities;

namespace AgroForecast.Application.Interfaces;

public interface IProductRepository
{
    Task<IEnumerable<Product>> GetAllProductsAsync();
}
