CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT,
    author TEXT,
    genre TEXT,
    price REAL
);

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    book_id INTEGER,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO books (title, author, genre, price) 
VALUES
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 12.99),
('1984', 'George Orwell', 'Science Fiction', 10.99),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 9.99),
('Pride and Prejudice', 'Jane Austen', 'Romance', 8.99),
('The Catcher in the Rye', 'J.D. Salinger', 'Fiction', 11.99);

INSERT INTO customers (name, email) 
VALUES
('Alice', 'alice@gmail.com'),
('Bob', 'bob@yahoo.com'),
('Charlie', 'charlie@outlook.com');

INSERT INTO purchases (customer_id, book_id, purchase_date) 
VALUES
(1, 1, '2024-04-25'), -- Alice purchased 'To Kill a Mockingbird'
(1, 3, '2024-04-27'), -- Alice purchased 'The Great Gatsby'
(2, 2, '2024-04-26'); -- Bob purchased '1984'