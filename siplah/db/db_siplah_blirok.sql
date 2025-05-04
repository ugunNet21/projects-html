
-- Mengatur database
CREATE DATABASE db_siplah_blirok;
USE db_siplah_blirok;

-- Tabel Users (menggunakan pendekatan Laravel Spatie untuk role dan permission)
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY, -- UUID
    npsn VARCHAR(20) NULL, -- Nomor Pokok Sekolah Nasional untuk sekolah
    npwp VARCHAR(20) NULL, -- Nomor Pokok Wajib Pajak untuk vendor
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    address TEXT NULL,
    legal_document_path VARCHAR(255) NULL, -- Dokumen legalitas usaha (vendor)
    is_verified BOOLEAN DEFAULT FALSE, -- Status verifikasi (untuk vendor)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Roles (dari Laravel Spatie)
CREATE TABLE roles (
    id CHAR(36) PRIMARY KEY, -- UUID
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Permissions (dari Laravel Spatie)
CREATE TABLE permissions (
    id CHAR(36) PRIMARY KEY, -- UUID
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Role-User (pivot table untuk role)
CREATE TABLE model_has_roles (
    role_id CHAR(36),
    model_id CHAR(36),
    model_type VARCHAR(255) NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel Permission-User (pivot table untuk permission)
CREATE TABLE model_has_permissions (
    permission_id CHAR(36),
    model_id CHAR(36),
    model_type VARCHAR(255) NOT NULL,
    PRIMARY KEY (permission_id, model_id, model_type),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel Funding Sources (Sumber Dana: BOS Reguler, BOSDA, dll.)
CREATE TABLE funding_sources (
    id CHAR(36) PRIMARY KEY, -- UUID
    name VARCHAR(100) NOT NULL, -- Contoh: BOS Reguler, BOSDA
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Categories (Kategori Barang/Jasa: Laptop, Meja, Buku, dll.)
CREATE TABLE categories (
    id CHAR(36) PRIMARY KEY, -- UUID
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Products (Katalog Produk dari Vendor)
CREATE TABLE products (
    id CHAR(36) PRIMARY KEY, -- UUID
    vendor_id CHAR(36) NOT NULL,
    category_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    price DECIMAL(15, 2) NOT NULL,
    stock INT NOT NULL,
    image_path VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

-- Tabel Procurements (Rencana Pengadaan oleh Sekolah)
CREATE TABLE procurements (
    id CHAR(36) PRIMARY KEY, -- UUID
    school_id CHAR(36) NOT NULL,
    funding_source_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    max_budget DECIMAL(15, 2) NOT NULL,
    status ENUM('draft', 'published', 'completed', 'canceled') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (funding_source_id) REFERENCES funding_sources(id) ON DELETE RESTRICT
);

-- Tabel Procurement Items (Detail Barang/Jasa dalam Pengadaan)
CREATE TABLE procurement_items (
    id CHAR(36) PRIMARY KEY, -- UUID
    procurement_id CHAR(36) NOT NULL,
    product_id CHAR(36) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    total_price DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (procurement_id) REFERENCES procurements(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- Tabel Orders (Pesanan setelah Checkout)
CREATE TABLE orders (
    id CHAR(36) PRIMARY KEY, -- UUID
    procurement_id CHAR(36) NOT NULL,
    school_id CHAR(36) NOT NULL,
    vendor_id CHAR(36) NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    payment_method ENUM('bank_transfer', 'direct_payment') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    shipping_status ENUM('pending', 'shipped', 'delivered', 'returned') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (procurement_id) REFERENCES procurements(id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel Order Items (Detail Barang dalam Pesanan)
CREATE TABLE order_items (
    id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NOT NULL,
    product_id CHAR(36) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    total_price DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- Tabel Documents (Dokumen Administrasi: RAB, SPP, Invoice, dll.)
CREATE TABLE documents (
    id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NULL,
    procurement_id CHAR(36) NULL,
    document_type ENUM('rab', 'spp', 'invoice', 'purchase_order', 'receipt', 'payment_proof', 'financial_report', 'realization_report', 'contract', 'tax_invoice') NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (procurement_id) REFERENCES procurements(id) ON DELETE CASCADE
);

-- Tabel Complaints (Komplain/Pengembalian Barang)
CREATE TABLE complaints (
    id CHAR(36) PRIMARY KEY, -- UUID
    order_id CHAR(36) NOT NULL,
    school_id CHAR(36) NOT NULL,
    vendor_id CHAR(36) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('pending', 'resolved', 'rejected') DEFAULT 'pending',
    resolution_note TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel Financial Reports (Laporan Keuangan)
CREATE TABLE financial_reports (
    id CHAR(36) PRIMARY KEY, -- UUID
    school_id CHAR(36) NOT NULL,
    funding_source_id CHAR(36) NOT NULL,
    period VARCHAR(20) NOT NULL, -- Contoh: Q1-2025
    total_budget DECIMAL(15, 2) NOT NULL,
    total_spent DECIMAL(15, 2) NOT NULL,
    remaining_budget DECIMAL(15, 2) NOT NULL,
    report_file_path VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (funding_source_id) REFERENCES funding_sources(id) ON DELETE RESTRICT
);

-- Tabel Activity Logs (Log Aktivitas untuk Audit)
CREATE TABLE activity_logs (
    id CHAR(36) PRIMARY KEY, -- UUID
    user_id CHAR(36) NOT NULL,
    action VARCHAR(255) NOT NULL, -- Contoh: create_procurement, update_order
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes untuk performa
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_procurements_school_id ON procurements(school_id);
CREATE INDEX idx_products_vendor_id ON products(vendor_id);
CREATE INDEX idx_documents_order_id ON documents(order_id);
CREATE INDEX idx_complaints_order_id ON complaints(order_id);