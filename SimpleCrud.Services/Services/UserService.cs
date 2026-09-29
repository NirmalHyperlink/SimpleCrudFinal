using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using SimpleCrud.Models.DTOs;
using SimpleCrud.Repository.Interfaces;
using SimpleCrud.Repository.Models;
using SimpleCrud.Services.Interfaces;

namespace SimpleCrud.Services.Services;

public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;
    private readonly IMapper _mapper;
    private readonly IConfiguration _configuration;

    public UserService(IUserRepository userRepository, IMapper mapper, IConfiguration configuration)
    {
        _userRepository = userRepository;
        _mapper = mapper;
        _configuration = configuration;
    }

    public async Task<(bool Success, string Message)> RegisterAsync(RegisterDto dto)
    {
        // 1. Check if email already exists
        var existingUser = await _userRepository.GetByEmailAsync(dto.Email);
        if (existingUser != null)
        {
            return (false, "Email is already registered.");
        }

        // 2. Hash the password securely using PBKDF2
        string hashedPassword = HashPassword(dto.Password);

        // 3. Map RegisterDto to User entity using AutoMapper
        var user = _mapper.Map<User>(dto);
        user.PasswordHash = hashedPassword;
        user.CreatedDate = DateTime.UtcNow;
        user.IsDeleted = false;

        // 4. Save to database via repository
        await _userRepository.AddAsync(user);

        return (true, "Registration successful.");
    }

    public async Task<(bool Success, string? Token, string Message)> LoginAsync(LoginDto dto)
    {
        // 1. Find user by email
        var user = await _userRepository.GetByEmailAsync(dto.Email);
        if (user == null)
        {
            return (false, null, "Invalid email or password.");
        }

        // 2. Verify hashed password
        if (!VerifyPassword(dto.Password, user.PasswordHash))
        {
            return (false, null, "Invalid email or password.");
        }

        // 3. Generate JWT token
        string token = GenerateJwtToken(user);

        return (true, token, "Login successful.");
    }

    // Simple JWT generation method
    private string GenerateJwtToken(User user)
    {
        var jwtSettings = _configuration.GetSection("Jwt");
        var secretKey = jwtSettings["Key"] ?? "SimpleCrudDefaultSecretKeyMustBe32CharsOrMore!";
        var issuer = jwtSettings["Issuer"] ?? "SimpleCrud";
        var audience = jwtSettings["Audience"] ?? "SimpleCrudUsers";
        var expiryMinutes = int.TryParse(jwtSettings["ExpiryMinutes"], out var minutes) ? minutes : 60;

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Name),
            new Claim(ClaimTypes.Email, user.Email)
        };

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiryMinutes),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    // Password hashing using PBKDF2 (SHA-256)
    private static string HashPassword(string password)
    {
        byte[] salt = RandomNumberGenerator.GetBytes(16);
        byte[] hash = Rfc2898DeriveBytes.Pbkdf2(
            password: Encoding.UTF8.GetBytes(password),
            salt: salt,
            iterations: 100000,
            hashAlgorithm: HashAlgorithmName.SHA256,
            outputLength: 32
        );

        return $"{Convert.ToBase64String(salt)}:{Convert.ToBase64String(hash)}";
    }

    private static bool VerifyPassword(string password, string storedHash)
    {
        var parts = storedHash.Split(':');
        if (parts.Length != 2) return false;

        byte[] salt = Convert.FromBase64String(parts[0]);
        byte[] originalHash = Convert.FromBase64String(parts[1]);

        byte[] computedHash = Rfc2898DeriveBytes.Pbkdf2(
            password: Encoding.UTF8.GetBytes(password),
            salt: salt,
            iterations: 100000,
            hashAlgorithm: HashAlgorithmName.SHA256,
            outputLength: 32
        );

        return CryptographicOperations.FixedTimeEquals(originalHash, computedHash);
    }
}
