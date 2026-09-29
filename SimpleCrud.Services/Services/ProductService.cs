using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using SimpleCrud.Models.DTOs;
using SimpleCrud.Repository.Interfaces;
using SimpleCrud.Repository.Models;
using SimpleCrud.Services.Interfaces;

namespace SimpleCrud.Services.Services;

public class ProductService : IProductService
{
    private readonly IProductRepository _productRepository;
    private readonly IMapper _mapper;

    public ProductService(IProductRepository productRepository, IMapper mapper)
    {
        _productRepository = productRepository;
        _mapper = mapper;
    }

    public async Task<List<ProductDto>> GetAllAsync()
    {
        var products = await _productRepository.GetAllAsync();
        return _mapper.Map<List<ProductDto>>(products);
    }

    public async Task<ProductDto?> GetByIdAsync(int id)
    {
        var product = await _productRepository.GetByIdAsync(id);
        if (product == null)
        {
            return null;
        }

        return _mapper.Map<ProductDto>(product);
    }

    public async Task CreateAsync(ProductDto dto)
    {
        var product = _mapper.Map<Product>(dto);
        product.CreatedDate = DateTime.UtcNow;
        product.IsDeleted = false;

        await _productRepository.AddAsync(product);
    }

    public async Task UpdateAsync(ProductDto dto)
    {
        var product = await _productRepository.GetByIdAsync(dto.Id);
        if (product != null)
        {
            // Map changes from DTO onto existing entity
            _mapper.Map(dto, product);
            product.UpdatedDate = DateTime.UtcNow;

            await _productRepository.UpdateAsync(product);
        }
    }

    public async Task DeleteAsync(int id)
    {
        await _productRepository.SoftDeleteAsync(id);
    }
}
