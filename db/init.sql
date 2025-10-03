CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name varchar(50),
    price int 
);

INSERT INTO products(name,price) VALUES
('Laptop Gaming', 15000000),
('Laptop Office', 7000000),
('Keyboard', 500000),
('Mouse', 100000)
ON CONFLICT DO NOTHING; 
