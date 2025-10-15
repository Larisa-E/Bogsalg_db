USE Bogsalg;
SET NOCOUNT ON; -- stops “x row(s) affected” messages so the results panes are cleaner (doesn’t change behavior)

-- Ensure a 'Geografi' genre exists. N'…' means the string is Unicode
IF NOT EXISTS (SELECT 1 FROM dbo.genres WHERE name = N'Geografi')
    INSERT INTO dbo.genres(name) VALUES (N'Geografi');
-- Retrieves the integer key for that genre and stores it in a variable for later inserts.
DECLARE @GenreId INT = (SELECT TOP 1 genre_id FROM dbo.genres WHERE name = N'Geografi'); 

-- 1) INSERT: Add a new book (with optional fields)
IF NOT EXISTS (SELECT 1 FROM dbo.books WHERE isbn = '9781234567890')   -- Avoid duplicate PK errors if re-running.
BEGIN
    INSERT INTO dbo.books (
        isbn, title, author, pages, published, price, description, genre_id
    )
    VALUES (
        '9781234567890',                    -- isbn (natural primary key)
        N'Geografi for Alle',               -- title
        N'Niels Geograf',                   -- author
        250,                                -- pages (optional, must be > 0 when not NULL)
        2022,                               -- published (optional, must be 1400..current year)
        299.95,                             -- price (required, >= 0)
        N'En grundbog om geografi.',        -- description (optional)
        @GenreId                            -- FK to genres(genre_id)
    );
END

-- show the inserted book (with optional fields present)
SELECT isbn, title, author, pages, published, price, description, genre_id
FROM dbo.books
WHERE isbn = '9781234567890';