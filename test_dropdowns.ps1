$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

Write-Host "--- 1. Testing Register Page & Country Dropdown ---"
$regPage = Invoke-WebRequest -Uri "http://localhost:5073/Account/Register" -WebSession $session
Write-Host "Register Page Status: $($regPage.StatusCode)"
$hasCountries = $regPage.Content.Contains("United States") -and $regPage.Content.Contains("India") -and $regPage.Content.Contains("Canada")
Write-Host "Country options rendered in HTML: $hasCountries"

Write-Host "`n--- 2. Testing GetStates API for USA (CountryId = 1) ---"
$statesUSA = Invoke-RestMethod -Uri "http://localhost:5073/Account/GetStates?countryId=1" -WebSession $session
Write-Host "USA States Count: $($statesUSA.Count)"
$statesUSA | ForEach-Object { Write-Host " - State: $($_.name) (ID: $($_.id))" }

Write-Host "`n--- 3. Testing GetStates API for India (CountryId = 2) ---"
$statesIndia = Invoke-RestMethod -Uri "http://localhost:5073/Account/GetStates?countryId=2" -WebSession $session
Write-Host "India States Count: $($statesIndia.Count)"
$statesIndia | ForEach-Object { Write-Host " - State: $($_.name) (ID: $($_.id))" }

Write-Host "`n--- 4. Testing GetCities API for California (StateId = 1) ---"
$citiesCal = Invoke-RestMethod -Uri "http://localhost:5073/Account/GetCities?stateId=1" -WebSession $session
Write-Host "California Cities Count: $($citiesCal.Count)"
$citiesCal | ForEach-Object { Write-Host " - City: $($_.name) (ID: $($_.id))" }

Write-Host "`n--- 5. Testing GetCities API for Maharashtra (StateId = 4) ---"
$citiesMh = Invoke-RestMethod -Uri "http://localhost:5073/Account/GetCities?stateId=4" -WebSession $session
Write-Host "Maharashtra Cities Count: $($citiesMh.Count)"
$citiesMh | ForEach-Object { Write-Host " - City: $($_.name) (ID: $($_.id))" }

Write-Host "`n--- 6. Registering New User with Selected Country, State, City ---"
$tokenMatch = [regex]::Match($regPage.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

$regBody = @{
    "__RequestVerificationToken" = $token
    "Name" = "Alice Smith"
    "Email" = "alice.smith@example.com"
    "Password" = "Password@123"
    "ConfirmPassword" = "Password@123"
    "CountryId" = 2       # India
    "StateId" = 4         # Maharashtra
    "CityId" = 10         # Mumbai
}
$regPost = Invoke-WebRequest -Uri "http://localhost:5073/Account/Register" -Method Post -Body $regBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Registration Status: $($regPost.StatusCode), Redirect to: $($regPost.Headers.Location)"
