
-- Create database and use it
CREATE DATABASE IF NOT EXISTS db_siplah_blideep;
USE db_siplah_blideep;

-- 1. Core Tables

-- Table: roles
CREATE TABLE roles (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL DEFAULT 'web',
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, guard_name)
);

-- Table: permissions
CREATE TABLE permissions (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL DEFAULT 'web',
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, guard_name)
);

-- Table: users
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    address TEXT NULL,
    status VARCHAR(20) DEFAULT 'active',
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: model_has_roles
CREATE TABLE model_has_roles (
    role_id CHAR(36) NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id CHAR(36) NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- Table: model_has_permissions
CREATE TABLE model_has_permissions (
    permission_id CHAR(36) NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id CHAR(36) NOT NULL,
    PRIMARY KEY (permission_id, model_id, model_type),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

-- Table: role_has_permissions
CREATE TABLE role_has_permissions (
    permission_id CHAR(36) NOT NULL,
    role_id CHAR(36) NOT NULL,
    PRIMARY KEY (permission_id, role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 2. School or Buyer

-- Table: schools
CREATE TABLE schools (
    id CHAR(36) PRIMARY KEY,
    npsn VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    province_id CHAR(36) NOT NULL,
    regency_id CHAR(36) NOT NULL,
    district_id CHAR(36) NOT NULL,
    postal_code VARCHAR(10) NULL,
    phone VARCHAR(20) NULL,
    email VARCHAR(255) NULL,
    principal_name VARCHAR(255) NULL,
    principal_phone VARCHAR(20) NULL,
    bos_fund_balance DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: school_users
CREATE TABLE school_users (
    id CHAR(36) PRIMARY KEY,
    school_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    position VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(school_id, user_id)
);

-- 3. Vendor

-- Table: vendors
CREATE TABLE vendors (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    npwp VARCHAR(20) UNIQUE NOT NULL,
    business_license_number VARCHAR(50) NOT NULL,
    business_scope TEXT NOT NULL,
    address TEXT NOT NULL,
    province_id CHAR(36) NOT NULL,
    regency_id CHAR(36) NOT NULL,
    district_id CHAR(36) NOT NULL,
    postal_code VARCHAR(10) NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    pic_name VARCHAR(255) NOT NULL,
    pic_phone VARCHAR(20) NOT NULL,
    pic_position VARCHAR(100) NOT NULL,
    bank_account_number VARCHAR(50) NOT NULL,
    bank_account_name VARCHAR(255) NOT NULL,
    bank_name VARCHAR(255) NOT NULL,
    verification_status VARCHAR(20) DEFAULT 'pending',
    verification_notes TEXT NULL,
    verified_at TIMESTAMP NULL,
    verified_by CHAR(36) NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table: vendor_users
CREATE TABLE vendor_users (
    id CHAR(36) PRIMARY KEY,
    vendor_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    position VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(vendor_id, user_id)
);

-- 4. Product and Catalog

-- Table: product_categories
CREATE TABLE product_categories (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    parent_id CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES product_categories(id) ON DELETE SET NULL
);

-- Table: products
CREATE TABLE products (
    id CHAR(36) PRIMARY KEY,
    vendor_id CHAR(36) NOT NULL,
    category_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    specification JSON NULL,
    price DECIMAL(15,2) NOT NULL,
    discount_price DECIMAL(15,2) NULL,
    stock INT NOT NULL DEFAULT 0,
    weight DECIMAL(10,2) NULL,
    length DECIMAL(10,2) NULL,
    width DECIMAL(10,2) NULL,
    height DECIMAL(10,2) NULL,
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by CHAR(36) NULL,
    approved_at TIMESTAMP NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table: product_images
CREATE TABLE product_images (
    id CHAR(36) PRIMARY KEY,
    product_id CHAR(36) NOT NULL,
    url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Table: product_reviews
CREATE TABLE product_reviews (
    id CHAR(36) PRIMARY KEY,
    product_id CHAR(36) NOT NULL,
    school_id CHAR(36) NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
);

-- 5. Procurement Planning

-- Table: fund_sources
CREATE TABLE fund_sources (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: procurement_plans
CREATE TABLE procurement_plans (
    id CHAR(36) PRIMARY KEY,
    school_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NULL,
    fiscal_year INT NOT NULL,
    fund_source_id CHAR(36) NOT NULL,
    total_budget DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'draft',
    approved_by CHAR(36) NULL,
    approved_at TIMESTAMP NULL,
    rejection_reason TEXT NULL,
    created_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    FOREIGN KEY (fund_source_id) REFERENCES fund_sources(id) ON DELETE RESTRICT,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: procurement_items
CREATE TABLE procurement_items (
    id CHAR(36) PRIMARY KEY,
    procurement_plan_id CHAR(36) NOT NULL,
    product_category_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    quantity INT NOT NULL,
    budget_per_unit DECIMAL(15,2) NOT NULL,
    total_budget DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (procurement_plan_id) REFERENCES procurement_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (product_category_id) REFERENCES product_categories(id) ON DELETE RESTRICT
);

-- 6. Order Transaction

-- Table: orders
CREATE TABLE orders (
    id CHAR(36) PRIMARY KEY,
    school_id CHAR(36) NOT NULL,
    procurement_plan_id CHAR(36) NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    grand_total DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    payment_method VARCHAR(50) NULL,
    payment_due_date TIMESTAMP NULL,
    payment_reference VARCHAR(100) NULL,
    paid_at TIMESTAMP NULL,
    shipping_address TEXT NOT NULL,
    shipping_courier VARCHAR(50) NULL,
    shipping_tracking_number VARCHAR(100) NULL,
    notes TEXT NULL,
    created_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE RESTRICT,
    FOREIGN KEY (procurement_plan_id) REFERENCES procurement_plans(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: order_items
CREATE TABLE order_items (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    product_id CHAR(36) NOT NULL,
    vendor_id CHAR(36) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_price DECIMAL(15,2) NULL,
    total_price DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE RESTRICT
);

-- Table: order_payments
CREATE TABLE order_payments (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_reference VARCHAR(100) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    payment_proof_url VARCHAR(255) NULL,
    status VARCHAR(20) DEFAULT 'pending',
    verified_by CHAR(36) NULL,
    verified_at TIMESTAMP NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table: order_shippings
CREATE TABLE order_shippings (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    shipping_method VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100) NOT NULL,
    shipping_date TIMESTAMP NOT NULL,
    estimated_delivery_date TIMESTAMP NULL,
    actual_delivery_date TIMESTAMP NULL,
    receiver_name VARCHAR(255) NULL,
    receiver_signature_url VARCHAR(255) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Table: order_status_history
CREATE TABLE order_status_history (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    status VARCHAR(50) NOT NULL,
    description TEXT NULL,
    created_by CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- 7. Delivery Acceptance

-- Table: delivery_acceptances
CREATE TABLE delivery_acceptances (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    acceptance_date TIMESTAMP NOT NULL,
    acceptance_status VARCHAR(20) NOT NULL,
    notes TEXT NULL,
    accepted_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (accepted_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: delivery_acceptance_items
CREATE TABLE delivery_acceptance_items (
    id CHAR(36) PRIMARY KEY,
    delivery_acceptance_id CHAR(36) NOT NULL,
    order_item_id CHAR(36) NOT NULL,
    quantity_accepted INT NOT NULL,
    quantity_rejected INT NOT NULL DEFAULT 0,
    rejection_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (delivery_acceptance_id) REFERENCES delivery_acceptances(id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE
);

-- 8. Complaints and Returns

-- Table: complaints
CREATE TABLE complaints (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    school_id CHAR(36) NOT NULL,
    vendor_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open',
    resolution TEXT NULL,
    resolved_by CHAR(36) NULL,
    resolved_at TIMESTAMP NULL,
    created_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: complaint_attachments
CREATE TABLE complaint_attachments (
    id CHAR(36) PRIMARY KEY,
    complaint_id CHAR(36) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE
);

-- Table: returns
CREATE TABLE returns (
    id CHAR(36) PRIMARY KEY,
    complaint_id CHAR(36) NULL,
    order_id CHAR(36) NOT NULL,
    vendor_id CHAR(36) NOT NULL,
    school_id CHAR(36) NOT NULL,
    return_reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'requested',
    tracking_number VARCHAR(100) NULL,
    refund_amount DECIMAL(15,2) NULL,
    refund_date TIMESTAMP NULL,
    refund_method VARCHAR(50) NULL,
    processed_by CHAR(36) NULL,
    processed_at TIMESTAMP NULL,
    created_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE SET NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: return_items

CREATE TABLE return_items (
    id CHAR(36) PRIMARY KEY,
    return_id CHAR(36) NOT NULL,
    order_item_id CHAR(36) NOT NULL,
    quantity INT NOT NULL,
    reason TEXT NOT NULL,
    `condition` VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (return_id) REFERENCES returns(id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE RESTRICT
);

-- 9. Financial Reporting

-- Table: school_fund_allocations
CREATE TABLE school_fund_allocations (
    id CHAR(36) PRIMARY KEY,
    school_id CHAR(36) NOT NULL,
    fund_source_id CHAR(36) NOT NULL,
    fiscal_year INT NOT NULL,
    allocation_amount DECIMAL(15,2) NOT NULL,
    allocated_at TIMESTAMP NOT NULL,
    allocated_by CHAR(36) NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    FOREIGN KEY (fund_source_id) REFERENCES fund_sources(id) ON DELETE RESTRICT,
    FOREIGN KEY (allocated_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: school_fund_transactions
CREATE TABLE school_fund_transactions (
    id CHAR(36) PRIMARY KEY,
    school_id CHAR(36) NOT NULL,
    fund_source_id CHAR(36) NOT NULL,
    order_id CHAR(36) NULL,
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    balance_before DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    reference_number VARCHAR(100) NULL,
    description TEXT NULL,
    created_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    FOREIGN KEY (fund_source_id) REFERENCES fund_sources(id) ON DELETE RESTRICT,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: vendor_payments
CREATE TABLE vendor_payments (
    id CHAR(36) PRIMARY KEY,
    vendor_id CHAR(36) NOT NULL,
    order_id CHAR(36) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_reference VARCHAR(100) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    processed_by CHAR(36) NULL,
    processed_at TIMESTAMP NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE RESTRICT,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT,
    FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- 10. Document Management

-- Table: document_types
CREATE TABLE document_types (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: order_documents
CREATE TABLE order_documents (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    document_type_id CHAR(36) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INT NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    uploaded_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (document_type_id) REFERENCES document_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Table: procurement_documents
CREATE TABLE procurement_documents (
    id CHAR(36) PRIMARY KEY,
    procurement_plan_id CHAR(36) NOT NULL,
    document_type_id CHAR(36) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INT NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    uploaded_by CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (procurement_plan_id) REFERENCES procurement_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (document_type_id) REFERENCES document_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- 11. System Logs

-- Table: system_settings

CREATE TABLE system_settings (
    id CHAR(36) PRIMARY KEY,
    `key` VARCHAR(255) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: activity_logs
CREATE TABLE activity_logs (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NULL,
    description TEXT NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    method VARCHAR(10) NULL,
    url TEXT NULL,
    referrer TEXT NULL,
    request_data JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Table: notifications
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    related_id CHAR(36) NULL,
    related_type VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_school ON orders(school_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_vendor ON order_items(vendor_id);
CREATE INDEX idx_procurement_plans_school ON procurement_plans(school_id);
CREATE INDEX idx_complaints_order ON complaints(order_id);
CREATE INDEX idx_returns_order ON returns(order_id);
CREATE INDEX idx_school_fund_transactions_school ON school_fund_transactions(school_id);
CREATE INDEX idx_activity_logs_user ON activity_logs(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);

-- Initial Data

-- Insert default roles
INSERT INTO roles (id, name, guard_name, description) VALUES
    (UUID(), 'super_admin', 'web', 'Super Administrator with full access'),
    (UUID(), 'school_admin', 'web', 'School Administrator'),
    (UUID(), 'school_principal', 'web', 'School Principal'),
    (UUID(), 'school_treasurer', 'web', 'School Treasurer'),
    (UUID(), 'vendor_admin', 'web', 'Vendor Administrator'),
    (UUID(), 'vendor_staff', 'web', 'Vendor Staff'),
    (UUID(), 'system_admin', 'web', 'System Administrator');

-- Insert default fund sources
INSERT INTO fund_sources (id, name, code, description) VALUES
    (UUID(), 'BOS Reguler', 'BOS_REG', 'Dana Bantuan Operasional Sekolah Reguler'),
    (UUID(), 'BOSDA', 'BOSDA', 'Dana Bantuan Operasional Sekolah Daerah'),
    (UUID(), 'BOS Kinerja', 'BOS_KIN', 'Dana BOS Kinerja'),
    (UUID(), 'APBD', 'APBD', 'Anggaran Pendapatan dan Belanja Daerah'),
    (UUID(), 'APBN', 'APBN', 'Anggaran Pendapatan dan Belanja Negara');

-- Insert default document types
INSERT INTO document_types (id, name, description, is_required) VALUES
    (UUID(), 'RAB', 'Rencana Anggaran Belanja', TRUE),
    (UUID(), 'SPP/SP2P', 'Surat Permintaan Pembayaran', TRUE),
    (UUID(), 'Invoice', 'Invoice Pembelian', TRUE),
    (UUID(), 'PO', 'Purchase Order', TRUE),
    (UUID(), 'Berita Acara', 'Berita Acara Penerimaan Barang', TRUE),
    (UUID(), 'Kwitansi', 'Bukti Pembayaran', TRUE),
    (UUID(), 'Laporan BOS', 'Laporan Penggunaan Dana BOS', TRUE);