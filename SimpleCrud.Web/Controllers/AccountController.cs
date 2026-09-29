using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SimpleCrud.Models.DTOs;
using SimpleCrud.Services.Interfaces;

namespace SimpleCrud.Web.Controllers;

public class AccountController : Controller
{
    private readonly IUserService _userService;
    private readonly ILocationService _locationService;

    public AccountController(IUserService userService, ILocationService locationService)
    {
        _userService = userService;
        _locationService = locationService;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> Register()
    {
        if (User.Identity?.IsAuthenticated == true)
        {
            return RedirectToAction("Index", "Product");
        }

        ViewBag.Countries = await _locationService.GetCountriesAsync();
        return View();
    }

    [HttpPost]
    [AllowAnonymous]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Register(RegisterDto model)
    {
        if (!ModelState.IsValid)
        {
            ViewBag.Countries = await _locationService.GetCountriesAsync();
            return View(model);
        }

        var result = await _userService.RegisterAsync(model);
        if (!result.Success)
        {
            ModelState.AddModelError(string.Empty, result.Message);
            ViewBag.Countries = await _locationService.GetCountriesAsync();
            return View(model);
        }

        TempData["SuccessMessage"] = "Registration successful! Please login with your credentials.";
        return RedirectToAction(nameof(Login));
    }

    // Cascading Dropdown API: Get states by country
    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetStates(int countryId)
    {
        var states = await _locationService.GetStatesByCountryIdAsync(countryId);
        return Json(states);
    }

    // Cascading Dropdown API: Get cities by state
    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetCities(int stateId)
    {
        var cities = await _locationService.GetCitiesByStateIdAsync(stateId);
        return Json(cities);
    }

    [HttpGet]
    [AllowAnonymous]
    public IActionResult Login()
    {
        if (User.Identity?.IsAuthenticated == true)
        {
            return RedirectToAction("Index", "Product");
        }
        return View();
    }

    [HttpPost]
    [AllowAnonymous]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginDto model)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        var result = await _userService.LoginAsync(model);
        if (!result.Success || string.IsNullOrEmpty(result.Token))
        {
            ModelState.AddModelError(string.Empty, result.Message);
            return View(model);
        }

        // Store JWT token inside HttpOnly cookie
        Response.Cookies.Append("jwt_token", result.Token, new CookieOptions
        {
            HttpOnly = true,
            Secure = Request.IsHttps,
            SameSite = SameSiteMode.Lax,
            Expires = DateTimeOffset.UtcNow.AddMinutes(60)
        });

        return RedirectToAction("Index", "Product");
    }

    [HttpGet]
    [Authorize]
    public IActionResult Logout()
    {
        Response.Cookies.Delete("jwt_token", new CookieOptions
        {
            HttpOnly = true,
            Secure = Request.IsHttps,
            SameSite = SameSiteMode.Lax
        });
        return RedirectToAction(nameof(Login));
    }
}
