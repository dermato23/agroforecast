using AgroForecast.Application.DTOs;
using AgroForecast.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AgroForecast.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductRepository _repository;

    public ProductsController(IProductRepository repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetAllProducts()
    {
        var products = await _repository.GetAllProductsAsync();

        var dto = products.Select(p => new ProductDto
        {
            Id = p.ProductID,
            Name = p.StandardName,
            CategoryName = p.Category?.CategoryName ?? "Sin Categoría"
        });

        return Ok(dto);
    }
}
