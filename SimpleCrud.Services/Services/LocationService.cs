using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using SimpleCrud.Models.DTOs;
using SimpleCrud.Repository.Interfaces;
using SimpleCrud.Services.Interfaces;

namespace SimpleCrud.Services.Services;

public class LocationService : ILocationService
{
    private readonly ILocationRepository _locationRepository;
    private readonly IMapper _mapper;

    public LocationService(ILocationRepository locationRepository, IMapper mapper)
    {
        _locationRepository = locationRepository;
        _mapper = mapper;
    }

    public async Task<List<LookupDto>> GetCountriesAsync()
    {
        var countries = await _locationRepository.GetCountriesAsync();
        return _mapper.Map<List<LookupDto>>(countries);
    }

    public async Task<List<LookupDto>> GetStatesByCountryIdAsync(int countryId)
    {
        var states = await _locationRepository.GetStatesByCountryIdAsync(countryId);
        return _mapper.Map<List<LookupDto>>(states);
    }

    public async Task<List<LookupDto>> GetCitiesByStateIdAsync(int stateId)
    {
        var cities = await _locationRepository.GetCitiesByStateIdAsync(stateId);
        return _mapper.Map<List<LookupDto>>(cities);
    }
}
