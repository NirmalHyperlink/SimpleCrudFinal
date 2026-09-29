using System.Threading.Tasks;
using SimpleCrud.Models.DTOs;

namespace SimpleCrud.Services.Interfaces;

public interface IUserService
{
    Task<(bool Success, string Message)> RegisterAsync(RegisterDto dto);
    Task<(bool Success, string? Token, string Message)> LoginAsync(LoginDto dto);
}
