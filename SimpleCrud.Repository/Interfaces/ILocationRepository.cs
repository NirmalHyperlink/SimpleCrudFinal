using System.Collections.Generic;
using System.Threading.Tasks;
using SimpleCrud.Repository.Models;

namespace SimpleCrud.Repository.Interfaces;

public interface ILocationRepository
{
    Task<List<Country>> GetCountriesAsync();
    Task<List<State>> GetStatesByCountryIdAsync(int countryId);
    Task<List<City>> GetCitiesByStateIdAsync(int stateId);
}
