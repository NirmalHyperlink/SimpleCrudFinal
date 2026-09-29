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

        // Location lookups
        CreateMap<Country, LookupDto>();
        CreateMap<State, LookupDto>();
        CreateMap<City, LookupDto>();
    }
}
