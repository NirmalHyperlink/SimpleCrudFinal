using System.Collections.Generic;
using System.Threading.Tasks;
using SimpleCrud.Models.DTOs;

namespace SimpleCrud.Services.Interfaces;

public interface IProductService
{
    Task<List<ProductDto>> GetAllAsync();
    Task<ProductDto?> GetByIdAsync(int id);
    Task CreateAsync(ProductDto dto);
    Task UpdateAsync(ProductDto dto);
    Task DeleteAsync(int id);
}
