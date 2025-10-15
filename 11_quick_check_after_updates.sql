USE Bogsalg;
SET NOCOUNT ON; 

---- check after updates
SELECT * FROM dbo.books WHERE isbn = '9781234567890';