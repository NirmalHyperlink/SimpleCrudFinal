using AutoMapper;
using SimpleCrud.Models.DTOs;
using SimpleCrud.Repository.Models;

namespace SimpleCrud.Web.Mapping;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // Product <-> ProductDto
        CreateMap<Product, ProductDto>().ReverseMap();

        // RegisterDto <-> User
        CreateMap<RegisterDto, User>();
        CreateMap<User, RegisterDto>();
    }
}
