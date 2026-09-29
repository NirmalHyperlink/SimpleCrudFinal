$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

Write-Host "--- 1. Testing Home Page ---"
$homeRes = Invoke-WebRequest -Uri "http://localhost:5073/" -WebSession $session
Write-Host "Home Status: $($homeRes.StatusCode)"

Write-Host "`n--- 2. Fetching Register Form to extract Antiforgery Token ---"
$regGet = Invoke-WebRequest -Uri "http://localhost:5073/Account/Register" -WebSession $session
$tokenMatch = [regex]::Match($regGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value
Write-Host "Found Token: $(!([string]::IsNullOrEmpty($token)))"

Write-Host "`n--- 3. Testing Registration ---"
$regBody = @{
    "__RequestVerificationToken" = $token
    "Name" = "John Doe"
    "Email" = "john.doe@example.com"
    "Password" = "Password@123"
    "ConfirmPassword" = "Password@123"
}
$regPost = Invoke-WebRequest -Uri "http://localhost:5073/Account/Register" -Method Post -Body $regBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Register Status: $($regPost.StatusCode), Redirect to: $($regPost.Headers.Location)"

Write-Host "`n--- 4. Fetching Login Form to extract Antiforgery Token ---"
$loginGet = Invoke-WebRequest -Uri "http://localhost:5073/Account/Login" -WebSession $session
$tokenMatch = [regex]::Match($loginGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

Write-Host "`n--- 5. Testing Login & JWT Cookie Issuance ---"
$loginBody = @{
    "__RequestVerificationToken" = $token
    "Email" = "john.doe@example.com"
    "Password" = "Password@123"
}
$loginPost = Invoke-WebRequest -Uri "http://localhost:5073/Account/Login" -Method Post -Body $loginBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Login Status: $($loginPost.StatusCode), Redirect to: $($loginPost.Headers.Location)"

$cookies = $session.Cookies.GetCookies((New-Object System.Uri("http://localhost:5073/")))
$jwtCookie = $cookies["jwt_token"]
Write-Host "JWT Cookie Present: $(!($null -eq $jwtCookie))"
if ($jwtCookie) {
    Write-Host "JWT Value preview: $($jwtCookie.Value.Substring(0, 30))..."
}

Write-Host "`n--- 6. Testing Product Index (Protected with [Authorize]) ---"
$prodIndex = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
Write-Host "Product Index Status: $($prodIndex.StatusCode)"

Write-Host "`n--- 7. Fetching Create Product Form ---"
$createGet = Invoke-WebRequest -Uri "http://localhost:5073/Product/Create" -WebSession $session
$tokenMatch = [regex]::Match($createGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

Write-Host "`n--- 8. Testing Create Product ---"
$createBody = @{
    "__RequestVerificationToken" = $token
    "Name" = "Wireless Ergonomic Keyboard"
    "Description" = "Comfortable split keyboard with mechanical keys"
    "Price" = "129.99"
}
$createPost = Invoke-WebRequest -Uri "http://localhost:5073/Product/Create" -Method Post -Body $createBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Create Product Status: $($createPost.StatusCode), Redirect to: $($createPost.Headers.Location)"

Write-Host "`n--- 9. Verifying Product in List ---"
$prodIndexAfterCreate = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
$hasProduct = $prodIndexAfterCreate.Content.Contains("Wireless Ergonomic Keyboard")
Write-Host "Product present in Index view: $hasProduct"

Write-Host "`n--- 10. Fetching Edit Form for Product #1 ---"
$editGet = Invoke-WebRequest -Uri "http://localhost:5073/Product/Edit/1" -WebSession $session
$tokenMatch = [regex]::Match($editGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

Write-Host "`n--- 11. Testing Edit Product ---"
$editBody = @{
    "__RequestVerificationToken" = $token
    "Id" = "1"
    "Name" = "Wireless Ergonomic Keyboard Pro"
    "Description" = "Updated split keyboard with RGB and bluetooth"
    "Price" = "149.99"
}
$editPost = Invoke-WebRequest -Uri "http://localhost:5073/Product/Edit/1" -Method Post -Body $editBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Edit Product Status: $($editPost.StatusCode)"

Write-Host "`n--- 12. Testing Details View for Product #1 ---"
$detailsGet = Invoke-WebRequest -Uri "http://localhost:5073/Product/Details/1" -WebSession $session
Write-Host "Details View Status: $($detailsGet.StatusCode)"
$hasUpdatedName = $detailsGet.Content.Contains("Wireless Ergonomic Keyboard Pro")
Write-Host "Details View shows updated name: $hasUpdatedName"

Write-Host "`n--- 13. Testing Soft Delete for Product #1 ---"
$tokenMatch = [regex]::Match($detailsGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
# Or get fresh token from Index view
$indexForDelete = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
$tokenMatch = [regex]::Match($indexForDelete.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

$deleteBody = @{
    "__RequestVerificationToken" = $token
}
$deletePost = Invoke-WebRequest -Uri "http://localhost:5073/Product/Delete/1" -Method Post -Body $deleteBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Delete Product Status: $($deletePost.StatusCode)"

Write-Host "`n--- 14. Verifying Soft Delete in View (Product should no longer appear) ---"
$prodIndexAfterDelete = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
$hasDeletedProduct = $prodIndexAfterDelete.Content.Contains("Wireless Ergonomic Keyboard Pro")
Write-Host "Deleted Product still in Index view (expected: False): $hasDeletedProduct"

Write-Host "`n--- 15. Testing Logout ---"
$logoutRes = Invoke-WebRequest -Uri "http://localhost:5073/Account/Logout" -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Logout Status: $($logoutRes.StatusCode), Redirect to: $($logoutRes.Headers.Location)"

Write-Host "`n--- 16. Verifying Unauthorized Access Redirects to Login ---"
$unauthSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$unauthReq = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $unauthSession -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Unauthenticated Product Access Status: $($unauthReq.StatusCode), Location: $($unauthReq.Headers.Location)"
