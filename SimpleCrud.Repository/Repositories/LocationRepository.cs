using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SimpleCrud.Repository.Interfaces;
using SimpleCrud.Repository.Models;

namespace SimpleCrud.Repository.Repositories;

public class LocationRepository : ILocationRepository
{
    private readonly ApplicationDbContext _context;

    public LocationRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Country>> GetCountriesAsync()
    {
        return await _context.Countries
            .OrderBy(c => c.Name)
            .ToListAsync();
    }

    public async Task<List<State>> GetStatesByCountryIdAsync(int countryId)
    {
        return await _context.States
            .Where(s => s.CountryId == countryId)
            .OrderBy(s => s.Name)
            .ToListAsync();
    }

    public async Task<List<City>> GetCitiesByStateIdAsync(int stateId)
    {
        return await _context.Cities
            .Where(c => c.StateId == stateId)
            .OrderBy(c => c.Name)
            .ToListAsync();
    }
}
