-- Membuat database
CREATE DATABASE umkm_super_app;
USE umkm_super_app;

-- Fungsi untuk mengonversi UUID string ke BINARY(16)
DELIMITER //
CREATE FUNCTION uuid_to_bin(uuid CHAR(36))
RETURNS BINARY(16) DETERMINISTIC
BEGIN
    RETURN UNHEX(REPLACE(uuid, '-', ''));
END //
DELIMITER ;

-- Tabel untuk UMKM (tenant) dengan dukungan hierarki cabang
CREATE TABLE businesses (
    business_id BINARY(16) PRIMARY KEY,
    parent_business_id BINARY(16) NULL,
    name VARCHAR(255) NOT NULL,
    type ENUM('warung', 'minimarket', 'supermarket') NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_business_id) REFERENCES businesses(business_id) ON DELETE SET NULL,
    INDEX idx_business_name (name),
    INDEX idx_business_parent (parent_business_id)
);

-- Tabel untuk kategori produk
CREATE TABLE categories (
    category_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_category_business (business_id)
);

-- Tabel untuk pengguna (owner, karyawan, kasir)
CREATE TABLE users (
    user_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_user_business (business_id),
    INDEX idx_user_username (username)
);

-- Tabel untuk peran (roles)
CREATE TABLE roles (
    role_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_name_business (name, business_id),
    INDEX idx_role_business (business_id)
);

-- Tabel untuk izin (permissions)
CREATE TABLE permissions (
    permission_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    UNIQUE KEY uk_permission_name_business (name, business_id),
    INDEX idx_permission_business (business_id)
);

-- Tabel untuk menghubungkan pengguna dengan peran
CREATE TABLE user_has_roles (
    user_id BINARY(16) NOT NULL,
    role_id BINARY(16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    INDEX idx_user_role_user (user_id)
);

-- Tabel untuk menghubungkan pengguna dengan izin langsung
CREATE TABLE user_has_permissions (
    user_id BINARY(16) NOT NULL,
    permission_id BINARY(16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, permission_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE,
    INDEX idx_user_permission_user (user_id)
);

-- Tabel untuk menghubungkan peran dengan izin
CREATE TABLE role_has_permissions (
    role_id BINARY(16) NOT NULL,
    permission_id BINARY(16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE,
    INDEX idx_role_permission_role (role_id)
);

-- Tabel untuk metode pembayaran digital
CREATE TABLE payment_methods (
    payment_method_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    type ENUM('qris', 'ewallet', 'bank_transfer', 'card', 'crypto') NOT NULL,
    details JSON, -- Menyimpan metadata (contoh: nomor rekening, token, QR code)
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_payment_method_business (business_id)
);

-- Tabel untuk produk
CREATE TABLE products (
    product_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(50) UNIQUE,
    barcode VARCHAR(50),
    category_id BINARY(16),
    price DECIMAL(15,2) NOT NULL,
    cost_price DECIMAL(15,2),
    stock_quantity INT NOT NULL DEFAULT 0,
    low_stock_threshold INT DEFAULT 10,
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_product_business (business_id),
    INDEX idx_product_sku (sku),
    INDEX idx_product_category (category_id)
);

-- Tabel untuk prediksi stok berbasis AI
CREATE TABLE product_predictions (
    prediction_id BINARY(16) PRIMARY KEY,
    product_id BINARY(16) NOT NULL,
    business_id BINARY(16) NOT NULL,
    predicted_demand INT NOT NULL,
    prediction_date DATE NOT NULL,
    confidence_score DECIMAL(5,2), -- Skor kepercayaan model AI (0-100%)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_prediction_product (product_id),
    INDEX idx_prediction_business (business_id)
);

-- Tabel untuk pelanggan
CREATE TABLE customers (
    customer_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_customer_business (business_id),
    INDEX idx_customer_email (email)
);

-- Tabel untuk transaksi penjualan
CREATE TABLE sales (
    sale_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    customer_id BINARY(16),
    user_id BINARY(16) NOT NULL,
    payment_method_id BINARY(16),
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(15,2) NOT NULL,
    payment_method ENUM('cash', 'card', 'qris', 'digital_wallet', 'crypto') NOT NULL,
    status ENUM('completed', 'pending', 'refunded') NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id) ON DELETE SET NULL,
    INDEX idx_sale_business (business_id),
    INDEX idx_sale_date (sale_date),
    INDEX idx_sale_payment_method (payment_method_id)
);

-- Tabel untuk item penjualan
CREATE TABLE sale_items (
    sale_item_id BINARY(16) PRIMARY KEY,
    sale_id BINARY(16) NOT NULL,
    product_id BINARY(16) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0,
    subtotal DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_sale_item_sale (sale_id),
    INDEX idx_sale_item_product (product_id)
);

-- Tabel untuk pesanan online
CREATE TABLE orders (
    order_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    customer_id BINARY(16),
    payment_method_id BINARY(16),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(15,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL,
    shipping_address TEXT,
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id) ON DELETE SET NULL,
    INDEX idx_order_business (business_id),
    INDEX idx_order_date (order_date),
    INDEX idx_order_payment_method (payment_method_id)
);

-- Tabel untuk item pesanan
CREATE TABLE order_items (
    order_item_id BINARY(16) PRIMARY KEY,
    order_id BINARY(16) NOT NULL,
    product_id BINARY(16) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_order_item_order (order_id),
    INDEX idx_order_item_product (product_id)
);

-- Tabel untuk promosi
CREATE TABLE promotions (
    promotion_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    discount_value DECIMAL(15,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_promotion_business (business_id)
);

-- Tabel untuk pemasok
CREATE TABLE suppliers (
    supplier_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_supplier_business (business_id)
);

-- Tabel untuk pembelian stok dari pemasok
CREATE TABLE purchases (
    purchase_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    supplier_id BINARY(16) NOT NULL,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(15,2) NOT NULL,
    status ENUM('ordered', 'received', 'cancelled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    INDEX idx_purchase_business (business_id),
    INDEX idx_purchase_supplier (supplier_id)
);

-- Tabel untuk item pembelian
CREATE TABLE purchase_items (
    purchase_item_id BINARY(16) PRIMARY KEY,
    purchase_id BINARY(16) NOT NULL,
    product_id BINARY(16) NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_purchase_item_purchase (purchase_id),
    INDEX idx_purchase_item_product (product_id)
);

-- Tabel untuk langganan (model freemium/sewa fitur)
CREATE TABLE subscriptions (
    subscription_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive', 'expired') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    features JSON, -- Daftar fitur yang diaktifkan (contoh: ["pos", "ecommerce"])
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_subscription_business (business_id)
);

-- Tabel untuk shift karyawan
CREATE TABLE shifts (
    shift_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    user_id BINARY(16) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_shift_business (business_id),
    INDEX idx_shift_user (user_id)
);

-- Tabel untuk program CSR/Sustainability
CREATE TABLE csr_programs (
    csr_program_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type ENUM('donation', 'environmental', 'community') NOT NULL,
    target_amount DECIMAL(15,2),
    collected_amount DECIMAL(15,2) DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    INDEX idx_csr_business (business_id)
);

-- Tabel untuk donasi pelanggan ke program CSR
CREATE TABLE csr_donations (
    donation_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    csr_program_id BINARY(16) NOT NULL,
    customer_id BINARY(16),
    amount DECIMAL(15,2) NOT NULL,
    donation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    FOREIGN KEY (csr_program_id) REFERENCES csr_programs(csr_program_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    INDEX idx_donation_business (business_id),
    INDEX idx_donation_csr_program (csr_program_id)
);

-- Tabel untuk log audit (keamanan)
CREATE TABLE audit_logs (
    log_id BINARY(16) PRIMARY KEY,
    business_id BINARY(16) NOT NULL,
    user_id BINARY(16),
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BINARY(16),
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(business_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_audit_business (business_id),
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_created (created_at)
);

-- Trigger untuk update stok setelah penjualan
DELIMITER //
CREATE TRIGGER after_sale_item_insert
AFTER INSERT ON sale_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;

-- Trigger untuk update stok setelah pembelian diterima
DELIMITER //
CREATE TRIGGER after_purchase_item_insert
AFTER INSERT ON purchase_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity + NEW.quantity
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;

-- Trigger untuk update collected_amount di csr_programs setelah donasi
DELIMITER //
CREATE TRIGGER after_csr_donation_insert
AFTER INSERT ON csr_donations
FOR EACH ROW
BEGIN
    UPDATE csr_programs
    SET collected_amount = collected_amount + NEW.amount
    WHERE csr_program_id = NEW.csr_program_id;
END //
DELIMITER ;

-- Contoh data untuk peran dan izin
INSERT INTO roles (role_id, business_id, name, description) VALUES 
(uuid_to_bin(UUID()), uuid_to_bin('550e8400-e29b-41d4-a716-446655440000'), 'owner', 'Full access to all features'),
(uuid_to_bin(UUID()), uuid_to_bin('550e8400-e29b-41d4-a716-446655440000'), 'cashier', 'Access to POS and sales');

INSERT INTO permissions (permission_id, business_id, name, description) VALUES 
(uuid_to_bin(UUID()), uuid_to_bin('550e8400-e29b-41d4-a716-446655440000'), 'manage_inventory', 'Can add/edit/delete products'),
(uuid_to_bin(UUID()), uuid_to_bin('550e8400-e29b-41d4-a716-446655440000'), 'process_sales', 'Can process sales transactions');

INSERT INTO role_has_permissions (role_id, permission_id) 
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p ON p.name = 'manage_inventory'
WHERE r.name = 'owner';

-- Contoh data untuk metode pembayaran
INSERT INTO payment_methods (payment_method_id, business_id, type, details, is_active) VALUES 
(uuid_to_bin(UUID()), uuid_to_bin('550e8400-e29b-41d4-a716-446655440000'), 'qris', '{"provider": "GoPay", "qr_code": "abc123"}', TRUE),
(uuid_to_bin(UUID()), uuid_to_bin('550e8400-e29b-41d4-a716-446655440000'), 'ewallet', '{"provider": "OVO", "account_id": "xyz789"}', TRUE);

-- Contoh data untuk langganan
INSERT INTO subscriptions (subscription_id, business_id, plan_name, status, start_date, end_date, features) VALUES 
(uuid_to_bin(UUID()), uuid_to_bin('550e8400-e29b-41d4-a716-446655440000'), 'premium', 'active', '2025-05-13', '2026-05-13', '["pos", "ecommerce", "analytics"]');

-- Contoh query untuk laporan penjualan harian
SELECT DATE(s.sale_date) AS sale_date,
       COUNT(s.sale_id) AS total_transactions,
       SUM(si.subtotal) AS total_revenue
FROM sales s
JOIN sale_items si ON s.sale_id = si.sale_id
WHERE s.business_id = uuid_to_bin('550e8400-e29b-41d4-a716-446655440000')
GROUP BY DATE(s.sale_date);

-- Contoh query untuk produk dengan stok rendah
SELECT p.name, p.stock_quantity, p.low_stock_threshold
FROM products p
WHERE p.business_id = uuid_to_bin('550e8400-e29b-41d4-a716-446655440000')
AND p.stock_quantity <= p.low_stock_threshold;

-- Contoh query untuk memeriksa izin pengguna
SELECT p.name
FROM users u
JOIN user_has_roles uhr ON u.user_id = uhr.user_id
JOIN role_has_permissions rhp ON uhr.role_id = rhp.role_id
JOIN permissions p ON rhp.permission_id = p.permission_id
WHERE u.user_id = uuid_to_bin('550e8400-e29b-41d4-a716-446655440001')
AND u.business_id = uuid_to_bin('550e8400-e29b-41d4-a716-446655440000');

-- Contoh query untuk prediksi stok
SELECT p.name, pp.predicted_demand, pp.confidence_score
FROM products p
JOIN product_predictions pp ON p.product_id = pp.product_id
WHERE p.business_id = uuid_to_bin('550e8400-e29b-41d4-a716-446655440000')
AND pp.prediction_date = CURDATE();