USE Bogsalg;
SET NOCOUNT ON; -- stops “x row(s) affected” messages so the results panes are cleaner (doesn’t change behavior)

-- Ensure a 'Geografi' genre exists. N'…' means the string is Unicode
IF NOT EXISTS (SELECT 1 FROM dbo.genres WHERE name = N'Geografi')
    INSERT INTO dbo.genres(name) VALUES (N'Geografi');
-- Retrieves the integer key for that genre and stores it in a variable for later inserts.
DECLARE @GenreId INT = (SELECT TOP 1 genre_id FROM dbo.genres WHERE name = N'Geografi'); 

-- 2) INSERT: Add a new book without optional fields
IF NOT EXISTS (SELECT 1 FROM dbo.books WHERE isbn = '9781234500000')   
BEGIN
    INSERT INTO dbo.books (
        isbn, title, author, price, genre_id
    )
    VALUES (
        '9781234500000',                   
        N'Kort og Godt',                   
        N'Anna Kort',                       
        199.95,                             
        @GenreId                           
    );
END

-- show the inserted book (optional fields should be NULL)
SELECT isbn, title, author, pages, published, price, description, genre_id
FROM dbo.books
WHERE isbn = '9781234500000';