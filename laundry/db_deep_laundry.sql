-- Enable UUID functions
SET GLOBAL log_bin_trust_function_creators = 1;

-- Create database
CREATE DATABASE IF NOT EXISTS modern_laundry;
USE modern_laundry;

-- Enum tables first
CREATE TABLE laundry_service_types (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    base_price DECIMAL(10,2) NOT NULL,
    estimated_duration_hours INT,
    UNIQUE KEY (name)
);

CREATE TABLE garment_types (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    washing_instructions TEXT,
    dry_cleaning_eligible BOOLEAN DEFAULT FALSE,
    UNIQUE KEY (name)
);

CREATE TABLE payment_methods (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    is_online BOOLEAN DEFAULT FALSE,
    UNIQUE KEY (name)
);

CREATE TABLE order_statuses (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    is_active_status BOOLEAN DEFAULT TRUE,
    UNIQUE KEY (name)
);

-- Main tables with UUIDs
CREATE TABLE customers (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (phone),
    UNIQUE KEY (email)
);

CREATE TABLE staff (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (phone),
    UNIQUE KEY (email)
);

CREATE TABLE orders (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    customer_id BINARY(16) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pickup_date DATETIME,
    delivery_date DATETIME,
    total_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(10,2) NOT NULL,
    status_id TINYINT UNSIGNED NOT NULL,
    payment_method_id TINYINT UNSIGNED,
    is_paid BOOLEAN DEFAULT FALSE,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
    FOREIGN KEY (status_id) REFERENCES order_statuses(id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

CREATE TABLE order_items (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    order_id BINARY(16) NOT NULL,
    service_type_id TINYINT UNSIGNED NOT NULL,
    garment_type_id TINYINT UNSIGNED NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (service_type_id) REFERENCES laundry_service_types(id),
    FOREIGN KEY (garment_type_id) REFERENCES garment_types(id)
);

CREATE TABLE order_status_history (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    order_id BINARY(16) NOT NULL,
    status_id TINYINT UNSIGNED NOT NULL,
    changed_by BINARY(16),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (status_id) REFERENCES order_statuses(id),
    FOREIGN KEY (changed_by) REFERENCES staff(id)
);

CREATE TABLE inventory (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'detergent', 'fabric_softener', 'stain_remover', etc.
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL, -- 'liter', 'kg', 'piece', etc.
    low_stock_threshold DECIMAL(10,2),
    last_restock_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE machine_maintenance (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    machine_name VARCHAR(100) NOT NULL,
    machine_type VARCHAR(50) NOT NULL, -- 'washer', 'dryer', 'iron', etc.
    last_maintenance_date DATE NOT NULL,
    next_maintenance_date DATE NOT NULL,
    maintenance_notes TEXT,
    responsible_staff_id BINARY(16),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (responsible_staff_id) REFERENCES staff(id)
);

CREATE TABLE customer_notifications (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    customer_id BINARY(16) NOT NULL,
    order_id BINARY(16),
    notification_type VARCHAR(50) NOT NULL, -- 'status_update', 'promotion', 'payment_reminder'
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL
);

CREATE TABLE subscriptions (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    customer_id BINARY(16) NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    monthly_limit_kg DECIMAL(5,2),
    price DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

CREATE TABLE payment_transactions (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    order_id BINARY(16),
    subscription_id BINARY(16),
    amount DECIMAL(10,2) NOT NULL,
    payment_method_id TINYINT UNSIGNED NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_reference VARCHAR(100),
    status VARCHAR(20) NOT NULL, -- 'pending', 'completed', 'failed', 'refunded'
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

-- Insert enum values
INSERT INTO laundry_service_types (name, description, base_price, estimated_duration_hours) VALUES
('Regular Wash', 'Standard washing and folding', 15.00, 24),
('Express Wash', 'Fast service within 6 hours', 25.00, 6),
('Dry Cleaning', 'Professional dry cleaning', 30.00, 48),
('Premium Care', 'Special care for delicate items', 40.00, 72);

INSERT INTO garment_types (name, washing_instructions, dry_cleaning_eligible) VALUES
('Shirt', 'Wash in cold water, gentle cycle', TRUE),
('Pants', 'Wash in warm water, normal cycle', TRUE),
('Dress', 'Hand wash recommended', TRUE),
('Jacket', 'Dry clean only', TRUE),
('Underwear', 'Wash in hot water, bleach allowed', FALSE);

INSERT INTO payment_methods (name, is_online) VALUES
('Cash', FALSE),
('Credit Card', TRUE),
('Bank Transfer', TRUE),
('E-Wallet', TRUE);

INSERT INTO order_statuses (name, description, is_active_status) VALUES
('Received', 'Order received but not processed yet', TRUE),
('In Progress', 'Items being washed/cleaned', TRUE),
('Ready for Pickup', 'Order completed and ready', TRUE),
('Out for Delivery', 'Being delivered to customer', TRUE),
('Completed', 'Order delivered and closed', FALSE),
('Cancelled', 'Order was cancelled', FALSE);