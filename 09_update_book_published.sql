USE Bogsalg;
SET NOCOUNT ON; -- cleaner results

---- 9) UPDATE: Update the publication year
UPDATE dbo.books SET published = 2024 WHERE isbn = '9781234567890';

-- verify published
SELECT isbn, published
FROM dbo.books
WHERE isbn = '9781234567890';