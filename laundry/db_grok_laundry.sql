-- Database: laundry_management
CREATE DATABASE IF NOT EXISTS laundry_management;
USE laundry_management;

-- Table: customers
-- Menyimpan data pelanggan
CREATE TABLE customers (
    customer_id CHAR(36) PRIMARY KEY, -- UUID
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: employees
-- Menyimpan data karyawan (petugas laundry)
CREATE TABLE employees (
    employee_id CHAR(36) PRIMARY KEY, -- UUID
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    role ENUM('admin', 'staff', 'driver') NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Untuk login
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: services
-- Menyimpan jenis layanan (cuci basah, dry cleaning, setrika, dll.)
CREATE TABLE services (
    service_id CHAR(36) PRIMARY KEY, -- UUID
    service_name VARCHAR(100) NOT NULL,
    description TEXT,
    price_per_unit DECIMAL(10, 2) NOT NULL, -- Harga per kg atau per item
    unit_type ENUM('kg', 'item') NOT NULL,
    estimated_duration INT NOT NULL, -- Dalam jam
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: orders
-- Menyimpan data pesanan
CREATE TABLE orders (
    order_id CHAR(36) PRIMARY KEY, -- UUID
    customer_id CHAR(36) NOT NULL,
    employee_id CHAR(36), -- Petugas yang menangani (nullable)
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pickup_type ENUM('store', 'delivery') NOT NULL,
    delivery_address TEXT,
    status ENUM('pending', 'in_progress', 'washing', 'drying', 'ironing', 'ready', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
    total_weight DECIMAL(10, 2), -- Berat total (kg)
    total_price DECIMAL(10, 2) NOT NULL,
    estimated_completion TIMESTAMP,
    notes TEXT, -- Catatan khusus dari pelanggan
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Table: order_items
-- Menyimpan detail item dalam pesanan
CREATE TABLE order_items (
    order_item_id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NOT NULL,
    service_id CHAR(36) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL, -- Jumlah (kg atau item)
    price DECIMAL(10, 2) NOT NULL, -- Harga per unit saat pemesanan
    item_description TEXT, -- Deskripsi item (misalnya: "Kemeja Putih")
    special_instructions TEXT, -- Instruksi khusus (misalnya: "Jangan pakai pewangi")
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

-- Table: payments
-- Menyimpan data pembayaran
CREATE TABLE payments (
    payment_id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'card', 'bank_transfer', 'digital_wallet') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(100), -- ID transaksi dari gateway pembayaran
    payment_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Table: order_status_logs
-- Melacak perubahan status pesanan untuk audit trail
CREATE TABLE order_status_logs (
    log_id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NOT NULL,
    status ENUM('pending', 'in_progress', 'washing', 'drying', 'ironing', 'ready', 'delivered', 'cancelled') NOT NULL,
    changed_by CHAR(36), -- Employee yang mengubah status
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT, -- Catatan terkait perubahan status
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (changed_by) REFERENCES employees(employee_id)
);

-- Table: notifications
-- Menyimpan notifikasi untuk pelanggan
CREATE TABLE notifications (
    notification_id CHAR(36) PRIMARY KEY, -- UUID
    customer_id CHAR(36) NOT NULL,
    order_id CHAR(36),
    message TEXT NOT NULL,
    notification_type ENUM('sms', 'email', 'push') NOT NULL,
    status ENUM('sent', 'pending', 'failed') NOT NULL DEFAULT 'pending',
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Table: inventory
-- Menyimpan data stok bahan (deterjen, pewangi, dll.)
CREATE TABLE inventory (
    inventory_id CHAR(36) PRIMARY KEY, -- UUID
    item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL, -- Dalam liter atau kg
    unit_type VARCHAR(20) NOT NULL, -- Misalnya: liter, kg
    minimum_stock DECIMAL(10, 2) NOT NULL, -- Batas minimum stok
    last_restocked TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: delivery_schedules
-- Menyimpan jadwal pengantaran
CREATE TABLE delivery_schedules (
    schedule_id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NOT NULL,
    driver_id CHAR(36), -- Karyawan yang bertugas mengantar
    scheduled_time TIMESTAMP NOT NULL,
    status ENUM('scheduled', 'in_transit', 'delivered', 'cancelled') NOT NULL DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (driver_id) REFERENCES employees(employee_id)
);

-- Table: customer_feedback
-- Menyimpan umpan balik pelanggan
CREATE TABLE customer_feedback (
    feedback_id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NOT NULL,
    customer_id CHAR(36) NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Table: promotions
-- Menyimpan data promosi/diskon
CREATE TABLE promotions (
    promotion_id CHAR(36) PRIMARY KEY, -- UUID
    promotion_name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5, 2), -- Persentase diskon
    valid_from TIMESTAMP NOT NULL,
    valid_until TIMESTAMP NOT NULL,
    service_id CHAR(36), -- Jika promosi spesifik untuk layanan tertentu
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(service_id)
);

-- Indexes for performance optimization
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_order_customer ON orders(customer_id);
CREATE INDEX idx_order_status ON orders(status);
CREATE INDEX idx_payment_order ON payments(order_id);
CREATE INDEX idx_notification_customer ON notifications(customer_id);

-- Example UUID function (if not using a library to generate UUID)
DELIMITER //
CREATE FUNCTION uuid_v4()
RETURNS CHAR(36)
DETERMINISTIC
BEGIN
    RETURN LOWER(CONCAT(
        HEX(RANDOM_BYTES(4)),
        '-',
        HEX(RANDOM_BYTES(2)),
        '-4',
        SUBSTR(HEX(RANDOM_BYTES(2)), 2, 3),
        '-',
        HEX(FLOOR(RAND() * 4) + 8),
        SUBSTR(HEX(RANDOM_BYTES(2)), 2, 3),
        '-',
        HEX(RANDOM_BYTES(6))
    ));
END //
DELIMITER ;