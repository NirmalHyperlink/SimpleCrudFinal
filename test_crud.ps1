$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

Write-Host "=== 1. Login with user created earlier (john.doe@example.com) ==="
$loginGet = Invoke-WebRequest -Uri "http://localhost:5073/Account/Login" -WebSession $session
$tokenMatch = [regex]::Match($loginGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

$loginBody = @{
    "__RequestVerificationToken" = $token
    "Email" = "john.doe@example.com"
    "Password" = "Password@123"
}
$loginPost = Invoke-WebRequest -Uri "http://localhost:5073/Account/Login" -Method Post -Body $loginBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue

Write-Host "Login response status: $($loginPost.StatusCode)"
$setCookie = $loginPost.Headers["Set-Cookie"]
Write-Host "Set-Cookie Header: $setCookie"

# If session didn't auto-save due to 302:
if ($setCookie) {
    $jwtValMatch = [regex]::Match($setCookie, 'jwt_token=([^;]+)')
    if ($jwtValMatch.Success) {
        $jwtVal = $jwtValMatch.Groups[1].Value
        $c = New-Object System.Net.Cookie("jwt_token", $jwtVal, "/", "localhost")
        $session.Cookies.Add($c)
        Write-Host "Manually attached jwt_token cookie to session."
    }
}

Write-Host "`n=== 2. Access Product Index ==="
$prodIndex = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
Write-Host "Product Index Status: $($prodIndex.StatusCode)"

Write-Host "`n=== 3. Create Product ==="
$createGet = Invoke-WebRequest -Uri "http://localhost:5073/Product/Create" -WebSession $session
$tokenMatch = [regex]::Match($createGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

$createBody = @{
    "__RequestVerificationToken" = $token
    "Name" = "Wireless Keyboard"
    "Description" = "RGB mechanical keyboard"
    "Price" = "79.99"
}
$createPost = Invoke-WebRequest -Uri "http://localhost:5073/Product/Create" -Method Post -Body $createBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Create Product Status: $($createPost.StatusCode), Redirect to: $($createPost.Headers.Location)"

Write-Host "`n=== 4. Check Product in Index ==="
$prodIndex2 = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
$hasProduct = $prodIndex2.Content.Contains("Wireless Keyboard")
Write-Host "Product found in Index: $hasProduct"

# Extract product ID
$idMatch = [regex]::Match($prodIndex2.Content, 'href="/Product/Details/(\d+)"')
$prodId = $idMatch.Groups[1].Value
Write-Host "Created Product ID: $prodId"

Write-Host "`n=== 5. View Details ==="
$detailsGet = Invoke-WebRequest -Uri "http://localhost:5073/Product/Details/$prodId" -WebSession $session
Write-Host "Details View Status: $($detailsGet.StatusCode)"
Write-Host "Details contains 'RGB mechanical keyboard': $($detailsGet.Content.Contains('RGB mechanical keyboard'))"

Write-Host "`n=== 6. Edit Product ==="
$editGet = Invoke-WebRequest -Uri "http://localhost:5073/Product/Edit/$prodId" -WebSession $session
$tokenMatch = [regex]::Match($editGet.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value

$editBody = @{
    "__RequestVerificationToken" = $token
    "Id" = $prodId
    "Name" = "Wireless Keyboard Pro"
    "Description" = "RGB mechanical keyboard with Bluetooth"
    "Price" = "99.99"
}
$editPost = Invoke-WebRequest -Uri "http://localhost:5073/Product/Edit/$prodId" -Method Post -Body $editBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Edit Product Status: $($editPost.StatusCode)"

$detailsAfterEdit = Invoke-WebRequest -Uri "http://localhost:5073/Product/Details/$prodId" -WebSession $session
Write-Host "Details shows updated name 'Wireless Keyboard Pro': $($detailsAfterEdit.Content.Contains('Wireless Keyboard Pro'))"
Write-Host "Details shows updated price '99.99': $($detailsAfterEdit.Content.Contains('99.99'))"

Write-Host "`n=== 7. Soft Delete Product ==="
$tokenMatch = [regex]::Match($detailsAfterEdit.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
if (-not $tokenMatch.Success) {
    $indexForDel = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
    $tokenMatch = [regex]::Match($indexForDel.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
}
$token = $tokenMatch.Groups[1].Value

$delBody = @{
    "__RequestVerificationToken" = $token
}
$delPost = Invoke-WebRequest -Uri "http://localhost:5073/Product/Delete/$prodId" -Method Post -Body $delBody -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Host "Delete Product Status: $($delPost.StatusCode)"

Write-Host "`n=== 8. Verify Soft Delete in Index View ==="
$indexAfterDel = Invoke-WebRequest -Uri "http://localhost:5073/Product/Index" -WebSession $session
$stillInIndex = $indexAfterDel.Content.Contains("Wireless Keyboard Pro")
Write-Host "Product still in active Index view (expected: False): $stillInIndex"
