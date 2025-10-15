-- Bogsalg schema for MS SQL Server (supports multiple books per order)
SET NOCOUNT ON;

IF DB_ID('Bogsalg') IS NULL
    CREATE DATABASE Bogsalg;
GO

USE Bogsalg;
GO

-- Clean re-run: drop in dependency order (child ? parent)
IF OBJECT_ID('dbo.order_items','U') IS NOT NULL DROP TABLE dbo.order_items;
IF OBJECT_ID('dbo.orders','U')       IS NOT NULL DROP TABLE dbo.orders;
IF OBJECT_ID('dbo.books','U')        IS NOT NULL DROP TABLE dbo.books;
IF OBJECT_ID('dbo.genres','U')       IS NOT NULL DROP TABLE dbo.genres;
IF OBJECT_ID('dbo.customers','U')    IS NOT NULL DROP TABLE dbo.customers;
IF OBJECT_ID('dbo.admin','U')        IS NOT NULL DROP TABLE dbo.admin;
GO

-- GENRES
CREATE TABLE dbo.genres (
    genre_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL
);

-- BOOKS
CREATE TABLE dbo.books (
    isbn VARCHAR(20) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    author NVARCHAR(100) NOT NULL,  
    pages INT NULL CHECK (pages IS NULL OR pages > 0), -- optional pages; if present, must be positive
    published INT NULL CHECK (published IS NULL OR (published BETWEEN 1400 AND YEAR(GETDATE()))), -- optional publication year; if present (not in the future and not OLDER THEN 1400)
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0), -- must be a positive price
    description NVARCHAR(1000) NULL,
    genre_id INT NOT NULL, -- linked to a genre
    FOREIGN KEY (genre_id) REFERENCES dbo.genres(genre_id) -- every book belongs to a genre
);
CREATE INDEX IX_books_genre_id ON dbo.books(genre_id); -- speeds up queries that filter or join on genre_id; without the index, SQL Server might scan the whole books table

-- CUSTOMERS
CREATE TABLE dbo.customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,  
    login NVARCHAR(200) NOT NULL UNIQUE, -- unique login (email)
    password NVARCHAR(50) NOT NULL,            
    firstname NVARCHAR(100) NULL,
    surname NVARCHAR(100) NULL,
    address NVARCHAR(200) NULL,
    city NVARCHAR(100) NULL,
    telephone NVARCHAR(50) NULL,
    zipcode NVARCHAR(20) NULL,
    email NVARCHAR(100) NOT NULL -- required email (separate from login). Tracks customer identities and contact info. Unique login enforces one account per login email
);

-- ORDERS
CREATE TABLE dbo.orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL -- the customer who placed the order
        REFERENCES dbo.customers(customer_id),
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0) -- non-negative
);
CREATE INDEX IX_orders_customer_id ON dbo.orders(customer_id);

-- ORDER_ITEMS
CREATE TABLE dbo.order_items (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL -- which order this line belongs to
        REFERENCES dbo.orders(order_id),
    book_isbn VARCHAR(20) NOT NULL -- which book is bought (references books.isbn)
        REFERENCES dbo.books(isbn),
    quantity INT NOT NULL CHECK (quantity > 0) -- how many copies (must be positive)
);
CREATE UNIQUE INDEX UX_order_items_order_book ON dbo.order_items(order_id, book_isbn); 
-- One line per (order, book). Use quantity to increase copies.

-- ADMIN
CREATE TABLE dbo.admin (
    admin_id INT IDENTITY(1,1) PRIMARY KEY,
    login NVARCHAR(200) NOT NULL UNIQUE,
    password NVARCHAR(100) NOT NULL
);

---- CHECK constraints: Keep data logical (positive numbers, reasonable years)
---- UNIQUE constraints: Prevent duplicate logins and duplicate book lines per order
---- Indexes: Improve performance for common joins (by genre and by customer)

---- Relationships (ER view)
--customers 1 — N orders
--orders 1 — N order_items
--books 1 — N order_items
--genres 1 — N books
--admin is standalone