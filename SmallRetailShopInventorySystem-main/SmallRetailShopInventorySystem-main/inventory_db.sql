-- Create the database
CREATE DATABASE IF NOT EXISTS retail_shop_db;
USE retail_shop_db;

-- 1. Users Table (FR1)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('OWNER', 'CASHIER', 'INVENTORY_STAFF') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Categories Table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Suppliers Table (FR7)
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT
);

-- 4. Products Table (FR2, FR3)
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT,
    supplier_id INT,
    model VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    low_stock_threshold INT DEFAULT 10,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL
);

-- 5. Sales Transactions Table (FR4, FR5)
CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('CASH', 'CREDIT_CARD', 'E-WALLET') DEFAULT 'CASH',
    payment_status ENUM('PAID', 'UNPAID') DEFAULT 'PAID',
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 6. Sale Items Table (Breakdown of products in a sale)
CREATE TABLE sale_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    sale_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 7. Inventory Logs Table (FR3.1 - History of updates)
CREATE TABLE inventory_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    user_id INT,
    change_quantity INT NOT NULL, -- Positive for addition, negative for deduction
    reason VARCHAR(255),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Seed Data
INSERT INTO users (username, password, full_name, role) VALUES 
('admin', 'admin123', 'Shop Owner', 'OWNER'),
('cashier1', 'cashier123', 'John Doe', 'CASHIER'),
('staff1', 'staff123', 'Jane Smith', 'INVENTORY_STAFF');

INSERT INTO categories (category_name) VALUES 
('Electronics'), ('Groceries'), ('Stationery'), ('Apparel');