USE Bogsalg;
SET NOCOUNT ON; -- stops “x row(s) affected” messages so the results panes are cleaner (doesn’t change behavior)

-- 3) INSERT: Create an order in orders for a customer who buys a book
--Steps: find/create customer -> create order header -> add order line

-- find customer
DECLARE @CustomerId INT;                                                -- Will hold the customer's numeric ID.
SELECT @CustomerId = customer_id                                        -- Try to reuse an existing customer by unique login.
FROM dbo.customers
WHERE login = N'test@kunde.dk';

-- create customer
IF @CustomerId IS NULL                                                  -- If not found, create the customer first.
BEGIN
    INSERT INTO dbo.customers (
        login, password, firstname, surname, address, city, telephone, zipcode, email
    )
    VALUES (
        N'test@kunde.dk',        -- login (unique)
        N'hemmeligt123',         -- password (store hashed in real systems)
        N'Test',                 -- firstname
        N'Kunde',                -- surname
        N'Vej 1',                -- address (optional)
        N'By',                   -- city (optional)
        N'12345678',             -- telephone (optional)
        N'1000',                 -- zipcode (optional)
        N'test@kunde.dk'         -- email (required)
    );
    SET @CustomerId = SCOPE_IDENTITY();                                 -- Get the new customer's identity value.
END

DECLARE @BookIsbn VARCHAR(20) = '9781234567890';                        -- Which book the customer buys.
DECLARE @Qty INT = 1;                                                   -- How many copies.
DECLARE @Price DECIMAL(10,2) = (SELECT price FROM dbo.books WHERE isbn = @BookIsbn);  -- Current unit price.

-- create order header (guarded so re-running doesn't create duplicates for same customer+ISBN)
IF NOT EXISTS (
  SELECT 1
  FROM dbo.orders o
  JOIN dbo.order_items oi ON oi.order_id = o.order_id
  WHERE o.customer_id = @CustomerId
    AND oi.book_isbn = @BookIsbn
)
BEGIN
    INSERT INTO dbo.orders (customer_id, order_date, total_amount)          -- Create the order header.
    VALUES (
        @CustomerId,                                                        -- Who placed the order.
        CAST(GETDATE() AS DATE),                                            -- Order date (today, no time).
        @Price * @Qty                                                       -- Simple total = unit price * quantity.
    );
    DECLARE @OrderId INT = SCOPE_IDENTITY();                                -- Capture the new order's ID.

    -- add order line
    INSERT INTO dbo.order_items (order_id, book_isbn, quantity)             -- Add the order line (detail).
    VALUES (
        @OrderId,                                                           -- Link to the order header.
        @BookIsbn,                                                          -- Which book.
        @Qty                                                                -- How many copies.
    );
END

-- Note: If you created the UNIQUE index on (order_id, book_isbn), you cannot add the same ISBN
-- as a second row for the same order; instead, UPDATE quantity to increase copies.


-- CHECKS:
-- A) How many orders for this customer that include this ISBN?
SELECT COUNT(*) AS matching_orders_for_customer_and_isbn
FROM dbo.orders o
JOIN dbo.order_items oi ON oi.order_id = o.order_id
WHERE o.customer_id = @CustomerId
  AND oi.book_isbn = @BookIsbn;

-- B) Show the most recent such order (header)
SELECT TOP 1 o.order_id, o.customer_id, o.order_date, o.total_amount
FROM dbo.orders o
JOIN dbo.order_items oi ON oi.order_id = o.order_id
WHERE o.customer_id = @CustomerId
  AND oi.book_isbn = @BookIsbn
ORDER BY o.order_id DESC;

-- C) Show the matching order lines (detail)
SELECT oi.order_item_id, oi.order_id, oi.book_isbn, oi.quantity
FROM dbo.order_items oi
JOIN dbo.orders o ON o.order_id = oi.order_id
WHERE o.customer_id = @CustomerId
  AND oi.book_isbn = @BookIsbn
ORDER BY oi.order_item_id DESC;