USE Bogsalg;
SET NOCOUNT ON; 

---- 8) UPDATE: Update the book title
UPDATE dbo.books SET title = N'Ny Titel' WHERE isbn = '9781234567890';

-- verify title
SELECT isbn, title
FROM dbo.books
WHERE isbn = '9781234567890';