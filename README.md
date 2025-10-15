# Bogsalg (Bookstore) Database

A small, production‑style relational database for a bookstore. It organizes customers, books, genres, orders, and order lines, and demonstrates common SQL operations (INSERT, SELECT, UPDATE) with safe, re‑runnable scripts. The schema is normalized and supports multiple different books (and multiple copies) in a single order.

Built for Microsoft SQL Server and tested in SSMS. The diagram is available as an image (diagram.png).

## What this project includes

- A normalized schema with these tables:
  - customers, orders, order_items, books, genres, admin
- Data integrity via primary keys, foreign keys, CHECK constraints, and recommended UNIQUE indexes
- Idempotent SQL scripts (safe to re‑run):
  - Inserts use `IF NOT EXISTS`
  - Order creation is guarded so the same customer+book isn’t double‑created on re‑runs
- Separate scripts per task (insert/select/update), each with a built‑in “check” query
- An ER diagram 

## Why this design

- One order can contain many books:
  - Implemented with the junction table `order_items(order_id, book_isbn, quantity)`
  - Recommended unique index `UNIQUE(order_id, book_isbn)` avoids duplicate lines; increase `quantity` instead
- Clear domain entities and relationships:
  - customers 1—N orders
  - orders 1—N order_items
  - books 1—N order_items
  - genres 1—N books
  - admin stands alone

## Scripts (how to run)

1) `schema.sql` — creates tables, keys, constraints, indexes (safe to re‑run)
2) Use the separate per‑task scripts in `tasks/` (each has a quick CHECK at the end)

## Evaluation and Design Considerations

Goal: Support a bookstore database with customers, books, orders, and genres, and allow a single order to include multiple books and multiple copies.

- Multiple books per order:
  - Implemented via a junction table `order_items` with a `quantity` column.
  - Recommended unique index `UNIQUE(order_id, book_isbn)` prevents duplicate lines; increase `quantity` instead.
- Data validation (examples):
  - `books.pages > 0` when provided
  - `books.published` between 1400 and current year when provided
  - `books.price >= 0`, `orders.total_amount >= 0`
- Performance:
  - Index FKs: `books(genre_id)`, `orders(customer_id)`, `order_items(order_id)`, `order_items(book_isbn)`.
- Security:
  - Store `password` fields as secure hashes (e.g., bcrypt/Argon2), not plain text.
- Idempotency:
  - Inserts are guarded with `IF NOT EXISTS`.
  - Order creation is guarded for the same customer+ISBN to avoid duplicates on re‑runs.

## Notes

- Unicode: using N'...' is safer if you ever insert non‑ASCII characters (æ, ø, å) now or later. Use for names/titles/descriptions/logins.
- Security: Passwords are plain text for demo; in real systems, store salted hashes (bcrypt/Argon2)
- Portability: Targets SQL Server. For MySQL, convert `IDENTITY`, `GETDATE()`, `SCOPE_IDENTITY()`, NVARCHAR, and some CHECK constraints.
