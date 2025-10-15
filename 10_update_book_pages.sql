USE Bogsalg;
SET NOCOUNT ON; -- cleaner results

---- 10) UPDATE: Update the page count
UPDATE dbo.books SET pages = 300 WHERE isbn = '9781234567890';

-- verify pages
SELECT isbn, pages
FROM dbo.books
WHERE isbn = '9781234567890';