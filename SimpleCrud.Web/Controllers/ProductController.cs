using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SimpleCrud.Models.DTOs;
using SimpleCrud.Services.Interfaces;

namespace SimpleCrud.Web.Controllers;

[Authorize]
public class ProductController : Controller
{
    private readonly IProductService _productService;

    public ProductController(IProductService productService)
    {
        _productService = productService;
    }

    // GET: /Product/Index
    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var products = await _productService.GetAllAsync();
        return View(products);
    }

    // GET: /Product/Details/5
    [HttpGet]
    public async Task<IActionResult> Details(int id)
    {
        var product = await _productService.GetByIdAsync(id);
        if (product == null)
        {
            return NotFound();
        }

        return View(product);
    }

    // GET: /Product/Create
    [HttpGet]
    public IActionResult Create()
    {
        return View();
    }

    // POST: /Product/Create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(ProductDto model)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        await _productService.CreateAsync(model);
        TempData["SuccessMessage"] = "Product created successfully!";
        return RedirectToAction(nameof(Index));
    }

    // GET: /Product/Edit/5
    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var product = await _productService.GetByIdAsync(id);
        if (product == null)
        {
            return NotFound();
        }

        return View(product);
    }

    // POST: /Product/Edit/5
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(ProductDto model)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        await _productService.UpdateAsync(model);
        TempData["SuccessMessage"] = "Product updated successfully!";
        return RedirectToAction(nameof(Index));
    }

    // POST: /Product/Delete/5 (Soft Delete)
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        await _productService.DeleteAsync(id);
        TempData["SuccessMessage"] = "Product deleted successfully!";
        return RedirectToAction(nameof(Index));
    }
}
