USE Bogsalg;
SET NOCOUNT ON;

-- 6) SELECT: get all books where the genre is ´Geografi´
SELECT b.*
FROM dbo.books b
JOIN dbo.genres g ON b.genre_id = g.genre_id
WHERE g.name = N'Geografi';