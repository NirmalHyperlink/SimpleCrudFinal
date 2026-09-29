using System.Threading.Tasks;
using SimpleCrud.Repository.Models;

namespace SimpleCrud.Repository.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByEmailAsync(string email);
    Task<User?> GetByIdAsync(int id);
    Task AddAsync(User user);
}
