using System.Collections.Generic;
using System.Threading.Tasks;
using SimpleCrud.Repository.Models;

namespace SimpleCrud.Repository.Interfaces;

public interface IProductRepository
{
    Task<List<Product>> GetAllAsync();
    Task<Product?> GetByIdAsync(int id);
    Task AddAsync(Product product);
    Task UpdateAsync(Product product);
    Task SoftDeleteAsync(int id);
}
