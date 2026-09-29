using System.Collections.Generic;
using System.Threading.Tasks;
using SimpleCrud.Models.DTOs;

namespace SimpleCrud.Services.Interfaces;

public interface ILocationService
{
    Task<List<LookupDto>> GetCountriesAsync();
    Task<List<LookupDto>> GetStatesByCountryIdAsync(int countryId);
    Task<List<LookupDto>> GetCitiesByStateIdAsync(int stateId);
}
