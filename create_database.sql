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
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Users') AND name = 'CountryId')
    BEGIN
        ALTER TABLE Users ADD CountryId INT NULL FOREIGN KEY REFERENCES Countries(Id);
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Users') AND name = 'StateId')
    BEGIN
        ALTER TABLE Users ADD StateId INT NULL FOREIGN KEY REFERENCES States(Id);
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Users') AND name = 'CityId')
    BEGIN
        ALTER TABLE Users ADD CityId INT NULL FOREIGN KEY REFERENCES Cities(Id);
    END
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
    -- Countries
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
