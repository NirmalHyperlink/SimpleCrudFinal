# Simple CRUD Application - ASP.NET Core 8 MVC

A clean, readable, and interview-ready **ASP.NET Core 8 MVC** application demonstrating an industry-standard layered architecture built with:
* **ASP.NET Core 8 MVC**
* **Entity Framework Core 8 (Database-First Approach)**
* **SQL Server**
* **Repository Pattern**
* **Service Layer**
* **AutoMapper**
* **DTOs (Data Transfer Objects)**
* **JWT Authentication** (stored in secure `HttpOnly` cookies for Razor Views)
* **Cascading Dropdowns** (Country &rarr; State &rarr; City)
* **Soft Delete Pattern**
* **Bootstrap 5 UI** with responsive layout and modals

---

## Architecture & Project Structure

The solution contains four decoupled projects with a clean, one-way dependency flow:

```text
SimpleCrud.Web (Presentation Layer: Controllers, Views, JWT Cookie Config, Mapping)
       ↓
SimpleCrud.Services (Business Logic Layer: UserService, ProductService, LocationService)
       ↓
SimpleCrud.Repository (Data Access Layer: ApplicationDbContext, Repositories, Scaffolded Models)
       ↓
SimpleCrud.Models (Data Transfer Layer: DTOs & View Models)
```

```text
SimpleCrud/
├── SimpleCrud.Web/               # MVC Web Application
│   ├── Controllers/
│   │   ├── AccountController.cs   # Register, Login, Logout, Cascading Dropdown APIs
│   │   ├── ProductController.cs   # Index, Details, Create, Edit, Soft Delete
│   │   └── HomeController.cs      # Landing page
│   ├── Views/
│   │   ├── Account/
│   │   │   ├── Register.cshtml    # Cascading Country -> State -> City dropdowns
│   │   │   └── Login.cshtml       # User authentication
│   │   ├── Product/
│   │   │   ├── Index.cshtml       # Product table with Soft Delete modal
│   │   │   ├── Create.cshtml      # Product creation form
│   │   │   ├── Edit.cshtml        # Product edit form
│   │   │   └── Details.cshtml     # Product details view
│   │   ├── Home/
│   │   │   └── Index.cshtml       # Dashboard & tech stack overview
│   │   └── Shared/
│   │       └── _Layout.cshtml     # Navigation bar with dynamic auth state
│   ├── Mapping/
│   │   └── MappingProfile.cs      # AutoMapper configuration
│   ├── Program.cs                 # DI registration, DbContext, JWT Bearer Events
│   └── appsettings.json           # Connection strings & JWT options
│
├── SimpleCrud.Services/          # Business Logic
│   ├── Interfaces/
│   │   ├── IUserService.cs
│   │   ├── IProductService.cs
│   │   └── ILocationService.cs
│   └── Services/
│       ├── UserService.cs         # Registration, PBKDF2 hashing, JWT generation
│       ├── ProductService.cs      # Product business logic & AutoMapper mapping
│       └── LocationService.cs     # Country, State, City lookup service
│
├── SimpleCrud.Repository/        # Database Access (Database First)
│   ├── Interfaces/
│   │   ├── IUserRepository.cs
│   │   ├── IProductRepository.cs
│   │   └── ILocationRepository.cs
│   ├── Repositories/
│   │   ├── UserRepository.cs      # EF Core queries for Users
│   │   ├── ProductRepository.cs   # EF Core queries & soft delete for Products
│   │   └── LocationRepository.cs  # EF Core queries for Countries, States, Cities
│   ├── Models/                    # Scaffolded from SQL Server
│   │   ├── User.cs
│   │   ├── Product.cs
│   │   ├── Country.cs
│   │   ├── State.cs
│   │   └── City.cs
│   └── ApplicationDbContext.cs    # Scaffolded DbContext
│
└── SimpleCrud.Models/            # DTOs
    └── DTOs/
        ├── RegisterDto.cs         # Registration form inputs + Country/State/City IDs
        ├── LoginDto.cs            # Login credentials
        ├── ProductDto.cs          # Product data contract
        └── LookupDto.cs           # Id & Name for dropdowns
```

---

## Prerequisites

Before running this project, ensure you have:
1. **.NET 8 SDK** installed ([Download .NET 8](https://dotnet.microsoft.com/download/dotnet/8.0))
2. **SQL Server** (SQL Server Express, LocalDB, or Developer Edition)
3. **SQL Server Management Studio (SSMS)**, **Azure Data Studio**, or `sqlcmd`
4. **Visual Studio 2022** (version 17.8+) or **VS Code** with C# Dev Kit

---

## Database Setup (Database-First)

This project strictly follows the **Database-First Approach**. The database and tables are created directly in SQL Server first, and EF Core models are scaffolded from the database.

### Complete SQL Script

Execute this script in SQL Server Management Studio (SSMS) or run `sqlcmd -S ".\SQLEXPRESS" -E -i create_database.sql`:

```sql
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SimpleCrudDb')
BEGIN
    CREATE DATABASE SimpleCrudDb;
END
GO

USE SimpleCrudDb;
GO

-- 1. Countries Table
IF OBJECT_ID(N'dbo.Countries', N'U') IS NULL
BEGIN
    CREATE TABLE Countries
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL
    );
END
GO

-- 2. States Table
IF OBJECT_ID(N'dbo.States', N'U') IS NULL
BEGIN
    CREATE TABLE States
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id)
    );
END
GO

-- 3. Cities Table
IF OBJECT_ID(N'dbo.Cities', N'U') IS NULL
BEGIN
    CREATE TABLE Cities
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        StateId INT NOT NULL FOREIGN KEY REFERENCES States(Id)
    );
END
GO

-- 4. Users Table
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE Users
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        Email NVARCHAR(200) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(500) NOT NULL,
        CountryId INT NULL FOREIGN KEY REFERENCES Countries(Id),
        StateId INT NULL FOREIGN KEY REFERENCES States(Id),
        CityId INT NULL FOREIGN KEY REFERENCES Cities(Id),
        CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 5. Products Table
IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
BEGIN
    CREATE TABLE Products
    (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL,
        Description NVARCHAR(1000) NULL,
        Price DECIMAL(18,2) NOT NULL,
        CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedDate DATETIME2 NULL,
        IsDeleted BIT NOT NULL DEFAULT 0
    );
END
GO

-- 6. Seed Sample Countries, States, and Cities
IF NOT EXISTS (SELECT 1 FROM Countries)
BEGIN
    INSERT INTO Countries (Name) VALUES ('United States'), ('India'), ('Canada');

    DECLARE @UsId INT = (SELECT Id FROM Countries WHERE Name = 'United States');
    DECLARE @InId INT = (SELECT Id FROM Countries WHERE Name = 'India');
    DECLARE @CaId INT = (SELECT Id FROM Countries WHERE Name = 'Canada');

    -- States for USA
    INSERT INTO States (Name, CountryId) VALUES 
    ('California', @UsId),
    ('Texas', @UsId),
    ('New York', @UsId);

    -- States for India
    INSERT INTO States (Name, CountryId) VALUES 
    ('Maharashtra', @InId),
    ('Karnataka', @InId),
    ('Gujarat', @InId);

    -- States for Canada
    INSERT INTO States (Name, CountryId) VALUES 
    ('Ontario', @CaId),
    ('British Columbia', @CaId);

    -- Cities for California
    DECLARE @CaStateId INT = (SELECT Id FROM States WHERE Name = 'California');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('Los Angeles', @CaStateId),
    ('San Francisco', @CaStateId),
    ('San Diego', @CaStateId);

    -- Cities for Texas
    DECLARE @TxStateId INT = (SELECT Id FROM States WHERE Name = 'Texas');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('Houston', @TxStateId),
    ('Austin', @TxStateId),
    ('Dallas', @TxStateId);

    -- Cities for New York
    DECLARE @NyStateId INT = (SELECT Id FROM States WHERE Name = 'New York');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('New York City', @NyStateId),
    ('Buffalo', @NyStateId),
    ('Albany', @NyStateId);

    -- Cities for Maharashtra
    DECLARE @MhStateId INT = (SELECT Id FROM States WHERE Name = 'Maharashtra');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('Mumbai', @MhStateId),
    ('Pune', @MhStateId),
    ('Nagpur', @MhStateId);

    -- Cities for Karnataka
    DECLARE @KaStateId INT = (SELECT Id FROM States WHERE Name = 'Karnataka');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('Bengaluru', @KaStateId),
    ('Mysuru', @KaStateId),
    ('Hubballi', @KaStateId);

    -- Cities for Gujarat
    DECLARE @GjStateId INT = (SELECT Id FROM States WHERE Name = 'Gujarat');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('Ahmedabad', @GjStateId),
    ('Surat', @GjStateId),
    ('Vadodara', @GjStateId);

    -- Cities for Ontario
    DECLARE @OnStateId INT = (SELECT Id FROM States WHERE Name = 'Ontario');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('Toronto', @OnStateId),
    ('Ottawa', @OnStateId),
    ('Mississauga', @OnStateId);

    -- Cities for British Columbia
    DECLARE @BcStateId INT = (SELECT Id FROM States WHERE Name = 'British Columbia');
    INSERT INTO Cities (Name, StateId) VALUES 
    ('Vancouver', @BcStateId),
    ('Victoria', @BcStateId),
    ('Kelowna', @BcStateId);
END
GO
```

---

## Scaffolding EF Core Models (Database-First)

If you modify the database schema in SQL Server, regenerate the models inside `SimpleCrud.Repository` using:

### Using Visual Studio Package Manager Console:
```powershell
Scaffold-DbContext "Server=.\SQLEXPRESS;Database=SimpleCrudDb;Trusted_Connection=True;TrustServerCertificate=True;" Microsoft.EntityFrameworkCore.SqlServer -OutputDir Models -ContextDir . -Context ApplicationDbContext -DataAnnotations -Project SimpleCrud.Repository -StartupProject SimpleCrud.Web -Force
```

### Using .NET CLI:
```powershell
dotnet ef dbcontext scaffold "Server=.\SQLEXPRESS;Database=SimpleCrudDb;Trusted_Connection=True;TrustServerCertificate=True;" Microsoft.EntityFrameworkCore.SqlServer --output-dir Models --context-dir . --context ApplicationDbContext --data-annotations --project SimpleCrud.Repository --startup-project SimpleCrud.Web --force
```

---

## Configuration (`appsettings.json`)

Configure your connection string and JWT secret key in `SimpleCrud.Web/appsettings.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=.\\SQLEXPRESS;Database=SimpleCrudDb;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "ThisIsASecretKeyForJwtAuthenticationSimpleCrudApp2026!",
    "Issuer": "SimpleCrud",
    "Audience": "SimpleCrudUsers",
    "ExpiryMinutes": 60
  }
}
```

> **Note:** If you are using LocalDB instead of SQL Server Express, change the server name to `(localdb)\\mssqllocaldb`.

---

## How to Run the Application

### Option 1: Using Visual Studio
1. Open `SimpleCrud.sln` in Visual Studio 2022.
2. Set `SimpleCrud.Web` as the **Startup Project** (Right-click `SimpleCrud.Web` &rarr; *Set as Startup Project*).
3. Press `F5` (or `Ctrl + F5`) to build and run.
4. The application opens at `http://localhost:5073` or `https://localhost:7083`.

### Option 2: Using .NET CLI
Open a terminal in the solution directory and run:

```bash
# 1. Restore packages
dotnet restore

# 2. Build the solution
dotnet build

# 3. Run the Web project
dotnet run --project SimpleCrud.Web --launch-profile http
```

5. Open your browser and navigate to:
   ```text
   http://localhost:5073
   ```

---

## Key Features & Interview Walkthrough

### 1. Registration with Cascading Dropdowns
* **URL:** `/Account/Register`
* Inputs: Full Name, Email, Password, Confirm Password, Country, State, City.
* **Cascading Logic:**
  * Selecting a **Country** triggers AJAX call to `/Account/GetStates?countryId={id}`.
  * The **State** dropdown is dynamically cleared, populated, and enabled.
  * Selecting a **State** triggers AJAX call to `/Account/GetCities?stateId={id}`.
  * The **City** dropdown is dynamically cleared, populated, and enabled.
* **Password Hashing:**
  * Passwords are never stored in plain text.
  * PBKDF2 (SHA-256) with unique cryptographic salt is used: `salt:hash`.
* AutoMapper maps `RegisterDto` to `User` entity, and `UserRepository` saves it to SQL Server.

### 2. Login & JWT Authentication
* **URL:** `/Account/Login`
* Validates credentials against SQL Server via `UserService`.
* Generates a signed **JWT Token** containing claims (`NameIdentifier`, `Name`, `Email`).
* **Why HttpOnly Cookie?**
  * In standard Razor MVC views, page transitions and HTML form submissions cannot manually set HTTP `Authorization: Bearer <token>` headers.
  * The JWT token is securely stored in an **`HttpOnly` cookie** (`jwt_token`), preventing XSS vulnerabilities.
  * In `Program.cs`, `JwtBearerEvents.OnMessageReceived` reads the cookie:
    ```csharp
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            if (context.Request.Cookies.ContainsKey("jwt_token"))
            {
                context.Token = context.Request.Cookies["jwt_token"];
            }
            return Task.CompletedTask;
        },
        OnChallenge = context =>
        {
            if (!context.Response.HasStarted)
            {
                context.HandleResponse();
                context.Response.Redirect("/Account/Login");
            }
            return Task.CompletedTask;
        }
    };
    ```
  * Unauthenticated users attempting to access protected pages are cleanly redirected to `/Account/Login`.

### 3. Product CRUD & Soft Delete
* **URL:** `/Product/Index` (Protected by `[Authorize]`)
* **List:** Displays only active records (`Where(x => !x.IsDeleted)`).
* **Create:** Takes `ProductDto`, maps to `Product` entity, sets `CreatedDate = DateTime.UtcNow`, saves via repository.
* **Edit:** Updates only `Name`, `Description`, `Price`, and sets `UpdatedDate`. Leaves `CreatedDate` and `IsDeleted` intact.
* **Details:** Displays non-deleted entity formatted with DTO.
* **Soft Delete:**
  * Clicking "Delete" displays a Bootstrap confirmation modal.
  * Clicking "Confirm Delete" executes:
    ```csharp
    product.IsDeleted = true;
    await _context.SaveChangesAsync();
    ```
  * The physical record remains preserved in SQL Server for data integrity and audits.

---

## Quick Verification Test (PowerShell)

You can run the included test script to verify all endpoints, database queries, and soft deletion:

```powershell
powershell -ExecutionPolicy Bypass -File test_crud.ps1
powershell -ExecutionPolicy Bypass -File test_dropdowns.ps1
```

---

## Summary of Layer Responsibilities

| Layer | Project | Responsibility |
|---|---|---|
| **Presentation** | `SimpleCrud.Web` | MVC Controllers, Razor Views, Bootstrap styling, Cookie extraction, AutoMapper profile |
| **Business Logic** | `SimpleCrud.Services` | Business rules, AutoMapper mapping, PBKDF2 hashing, JWT token generation |
| **Data Access** | `SimpleCrud.Repository` | EF Core `ApplicationDbContext`, Entity Models, CRUD operations, Soft Delete filter |
| **Models / DTOs** | `SimpleCrud.Models` | Data Transfer Objects (`RegisterDto`, `LoginDto`, `ProductDto`, `LookupDto`) |
