using System;
using System.ComponentModel.DataAnnotations;

namespace SimpleCrud.Models.DTOs;

public class ProductDto
{
    public int Id { get; set; }

    [Required(ErrorMessage = "Product name is required")]
    [StringLength(200, ErrorMessage = "Product name cannot exceed 200 characters")]
    public string Name { get; set; } = string.Empty;

    [StringLength(1000, ErrorMessage = "Description cannot exceed 1000 characters")]
    public string? Description { get; set; }

    [Required(ErrorMessage = "Price is required")]
    [Range(0.01, 10000000.00, ErrorMessage = "Price must be greater than 0")]
    public decimal Price { get; set; }

    [Display(Name = "Created Date")]
    public DateTime? CreatedDate { get; set; }

    [Display(Name = "Updated Date")]
    public DateTime? UpdatedDate { get; set; }
}
