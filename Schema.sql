-- ============================================
-- 1️⃣ CREATE DATABASE
-- ============================================

CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ============================================
-- 2️⃣ CREATE TABLES
-- ============================================

-- USERS TABLE
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    role ENUM('customer','seller','admin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CATEGORIES TABLE
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- PRODUCTS TABLE
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT,
    category_id INT,
    product_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(user_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- CART TABLE
CREATE TABLE cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    quantity INT DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ORDERS TABLE
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    total_amount DECIMAL(10,2),
    order_status ENUM('pending','shipped','delivered','cancelled') DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ORDER ITEMS TABLE
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- PAYMENTS TABLE
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE,
    payment_method ENUM('UPI','Credit Card','Debit Card','COD'),
    payment_status ENUM('success','failed','pending') DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- REVIEWS TABLE
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ============================================
-- 3️⃣ INSERT DEMO DATA
-- ============================================

-- USERS
INSERT INTO users (name, email, password, role)
VALUES
('Ishita Singh', 'ishita@gmail.com', '12345', 'customer'),
('Rahul Sharma', 'rahul@gmail.com', '12345', 'seller'),
('Admin User', 'admin@gmail.com', 'admin123', 'admin');

-- CATEGORIES
INSERT INTO categories (category_name)
VALUES ('Electronics'), ('Clothing'), ('Books');

-- PRODUCTS
INSERT INTO products (seller_id, category_id, product_name, description, price, stock)
VALUES
(2, 1, 'Smartphone', 'Latest 5G Smartphone', 15000.00, 10),
(2, 2, 'T-Shirt', 'Cotton Oversized T-Shirt', 799.00, 50),
(2, 3, 'DBMS Book', 'Complete Database Guide', 599.00, 25);

-- CART
INSERT INTO cart (user_id, product_id, quantity)
VALUES (1, 1, 1);

-- ORDERS
INSERT INTO orders (user_id, total_amount, order_status)
VALUES (1, 15000.00, 'pending');

-- ORDER ITEMS
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (1, 1, 1, 15000.00);

-- PAYMENTS
INSERT INTO payments (order_id, payment_method, payment_status)
VALUES (1, 'UPI', 'success');

-- REVIEWS
INSERT INTO reviews (product_id, user_id, rating, comment)
VALUES (1, 1, 5, 'Excellent product!');

-- ============================================
-- 4️⃣ EXECUTION QUERIES
-- ============================================

-- View All Users
SELECT * FROM users;

-- View All Products
SELECT * FROM products;

-- Products with Category Name
SELECT p.product_name, p.price, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- Orders with Customer Name
SELECT o.order_id, u.name, o.total_amount, o.order_status
FROM orders o
JOIN users u ON o.user_id = u.user_id;

-- Order Details with Product Name
SELECT o.order_id, p.product_name, oi.quantity, oi.price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id;

-- Total Orders by Each User
SELECT user_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY user_id;

-- Total Sales
SELECT SUM(total_amount) AS total_sales FROM orders;

-- Top Selling Products
SELECT product_id, SUM(quantity) AS total_sold
FROM order_items
GROUP BY product_id
ORDER BY total_sold DESC;

-- ============================================
-- 5️⃣ TRIGGER (AUTO REDUCE STOCK)
-- ============================================

DELIMITER //

CREATE TRIGGER reduce_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
   UPDATE products
   SET stock = stock - NEW.quantity
   WHERE product_id = NEW.product_id;
END//

DELIMITER ;

-- ============================================
-- 6️⃣ STORED PROCEDURE
-- ============================================

DELIMITER //

CREATE PROCEDURE GetUserOrders(IN uid INT)
BEGIN
   SELECT * FROM orders WHERE user_id = uid;
END//

DELIMITER ;

-- Call Procedure Example
CALL GetUserOrders(1);
