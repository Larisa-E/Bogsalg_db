USE Bogsalg;
SET NOCOUNT ON;

-- 5) SELECT: get all books
SELECT * FROM dbo.books;

-- quick count
SELECT COUNT(*) AS book_count FROM dbo.books;