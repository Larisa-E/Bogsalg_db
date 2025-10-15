USE Bogsalg;
SET NOCOUNT ON; -- cleaner results

-- 7) SELECT: Get all customers and the number of their orders (including those without orders)
SELECT 
    c.customer_id,
    c.firstname,
    c.surname,
    COUNT(o.order_id) AS antal_ordrer
FROM dbo.customers c
LEFT JOIN dbo.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.firstname, c.surname
ORDER BY c.customer_id;

-- CHECK: total customers and total orders
SELECT COUNT(*) AS customers_total FROM dbo.customers;
SELECT COUNT(*) AS orders_total FROM dbo.orders;