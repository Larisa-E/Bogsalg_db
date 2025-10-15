USE Bogsalg;
SET NOCOUNT ON; --cleanner result

-- 4) SELECT: get all genres
SELECT * FROM dbo.genres;

-- quick count
SELECT COUNT(*) AS genre_count FROM dbo.genres;