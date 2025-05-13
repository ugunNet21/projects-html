CREATE DATABASE masjid_app;
USE masjid_app;

-- Tabel untuk pengguna (jamaah, DKM, admin)
CREATE TABLE users (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36), -- Relasi ke masjid utama pengguna
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    password VARCHAR(255), -- Hashed password
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_email (email),
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE SET NULL
);

-- Tabel untuk masjid
CREATE TABLE mosques (
    id CHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE, -- Subdomain unik (misalnya, masjid-agung)
    address TEXT NOT NULL,
    city VARCHAR(100),
    province VARCHAR(100),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    logo_url VARCHAR(255), -- URL untuk logo masjid
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_subdomain (subdomain)
);

-- Tabel untuk peran
CREATE TABLE roles (
    id CHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE, -- Misalnya: admin, dkm, jamaah
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Tabel untuk izin
CREATE TABLE permissions (
    id CHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE, -- Misalnya: edit_event, view_donation
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Tabel untuk menghubungkan peran dengan izin
CREATE TABLE role_has_permissions (
    role_id CHAR(36) NOT NULL,
    permission_id CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

-- Tabel untuk menghubungkan pengguna dengan peran
CREATE TABLE user_has_roles (
    user_id CHAR(36) NOT NULL,
    role_id CHAR(36) NOT NULL,
    mosque_id CHAR(36), -- Untuk izin spesifik per masjid
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id, mosque_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE
);

-- Tabel untuk memberikan izin langsung ke pengguna
CREATE TABLE user_has_permissions (
    user_id CHAR(36) NOT NULL,
    permission_id CHAR(36) NOT NULL,
    mosque_id CHAR(36), -- Untuk izin spesifik per masjid
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, permission_id, mosque_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE
);

-- Tabel untuk donasi
CREATE TABLE donations (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36), -- Donatur
    mosque_id CHAR(36),
    amount DECIMAL(15, 2) NOT NULL,
    type ENUM('donation', 'zakat', 'wakaf') DEFAULT 'donation',
    payment_method ENUM('qr_code', 'bank_transfer', 'digital_wallet') NOT NULL,
    status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    transaction_id VARCHAR(100), -- ID dari payment gateway
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    INDEX idx_status (status)
);

-- Tabel untuk kegiatan masjid
CREATE TABLE events (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATETIME NOT NULL,
    location VARCHAR(255),
    is_online BOOLEAN DEFAULT FALSE,
    stream_url VARCHAR(255), -- Untuk live streaming
    status ENUM('draft', 'published', 'completed', 'canceled') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    INDEX idx_event_date (event_date)
);

-- Tabel untuk pendaftaran kegiatan
CREATE TABLE event_registrations (
    id CHAR(36) NOT NULL PRIMARY KEY,
    event_id CHAR(36),
    user_id CHAR(36),
    status ENUM('registered', 'attended', 'canceled') DEFAULT 'registered',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel untuk laporan fasilitas
CREATE TABLE facility_reports (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    user_id CHAR(36),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    photo_url VARCHAR(255), -- URL foto kerusakan
    status ENUM('reported', 'in_progress', 'resolved') DEFAULT 'reported',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status (status)
);

-- Tabel untuk konten edukasi
CREATE TABLE contents (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    title VARCHAR(255) NOT NULL,
    type ENUM('khutbah', 'article', 'video', 'podcast') DEFAULT 'article',
    content TEXT, -- Untuk teks (khutbah/artikel)
    media_url VARCHAR(255), -- Untuk video/podcast
    created_by CHAR(36), -- Pengunggah (DKM/admin)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel untuk postingan komunitas
CREATE TABLE community_posts (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    user_id CHAR(36),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel untuk notifikasi
CREATE TABLE notifications (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36),
    mosque_id CHAR(36),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('event', 'donation', 'facility', 'general') DEFAULT 'general',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE
);

-- Tabel untuk transaksi keuangan masjid (pemasukan/pengeluaran)
CREATE TABLE transactions (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    type ENUM('income', 'expense') NOT NULL,
    category VARCHAR(100), -- Misalnya: listrik, perawatan, donasi
    amount DECIMAL(15, 2) NOT NULL,
    description TEXT,
    created_by CHAR(36), -- Pengurus yang mencatat
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel untuk gamifikasi (poin dan badge)
CREATE TABLE user_rewards (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36),
    mosque_id CHAR(36),
    type ENUM('point', 'badge') NOT NULL,
    name VARCHAR(100), -- Nama badge atau deskripsi poin
    value INT DEFAULT 0, -- Jumlah poin atau 1 untuk badge
    description TEXT,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE
);

-- Tabel untuk aset wakaf
CREATE TABLE wakaf_assets (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    name VARCHAR(255) NOT NULL, -- Misalnya: Tanah 500m2, Toko
    description TEXT,
    type ENUM('land', 'building', 'vehicle', 'other') NOT NULL,
    value DECIMAL(15, 2), -- Nilai estimasi aset
    document_url VARCHAR(255), -- URL dokumen wakaf
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE
);

-- Tabel untuk transaksi wakaf (pendapatan/pengeluaran)
CREATE TABLE wakaf_transactions (
    id CHAR(36) NOT NULL PRIMARY KEY,
    wakaf_asset_id CHAR(36),
    mosque_id CHAR(36),
    type ENUM('income', 'expense') NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    description TEXT,
    created_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (wakaf_asset_id) REFERENCES wakaf_assets(id) ON DELETE CASCADE,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Tabel untuk audit log
CREATE TABLE audit_logs (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36),
    mosque_id CHAR(36),
    action VARCHAR(255) NOT NULL, -- Misalnya: create_event, update_role
    entity_type VARCHAR(100), -- Misalnya: event, user, donation
    entity_id CHAR(36), -- ID entitas yang diubah
    details JSON, -- Detail aksi (misalnya, data sebelum/sesudah)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE
);

-- Tabel untuk lokasi masjid (untuk jadwal sholat)
CREATE TABLE mosque_locations (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    timezone VARCHAR(50), -- Misalnya: Asia/Jakarta
    calculation_method ENUM('MWL', 'ISNA', 'Egypt', 'Makkah', 'Karachi') DEFAULT 'MWL', -- Metode perhitungan waktu sholat
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    UNIQUE KEY uk_mosque_id (mosque_id)
);

-- Tabel untuk relawan
CREATE TABLE volunteers (
    id CHAR(36) NOT NULL PRIMARY KEY,
    user_id CHAR(36),
    mosque_id CHAR(36),
    event_id CHAR(36), -- Jika relawan untuk kegiatan tertentu
    role VARCHAR(100), -- Misalnya: kebersihan, pengatur parkir
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL
);

-- Tabel untuk akun media sosial masjid
CREATE TABLE social_media_accounts (
    id CHAR(36) NOT NULL PRIMARY KEY,
    mosque_id CHAR(36),
    platform ENUM('instagram', 'whatsapp', 'twitter', 'facebook') NOT NULL,
    account_id VARCHAR(255) NOT NULL, -- ID akun di platform
    access_token VARCHAR(255), -- Token untuk API
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (mosque_id) REFERENCES mosques(id) ON DELETE CASCADE
);

-- Tabel untuk terjemahan konten (multi-language)
CREATE TABLE translations (
    id CHAR(36) NOT NULL PRIMARY KEY,
    entity_type VARCHAR(100), -- Misalnya: content, event, notification
    entity_id CHAR(36), -- ID entitas yang diterjemahkan
    language_code VARCHAR(10) NOT NULL, -- Misalnya: id, jv, su
    field VARCHAR(100) NOT NULL, -- Misalnya: title, description
    value TEXT NOT NULL, -- Nilai terjemahan
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Contoh data awal untuk roles dan permissions
INSERT INTO roles (id, name, description) VALUES
(UUID(), 'super_admin', 'Administrator sistem nasional'),
(UUID(), 'dkm', 'Pengurus masjid'),
(UUID(), 'jamaah', 'Jamaah biasa'),
(UUID(), 'volunteer', 'Relawan masjid');

INSERT INTO permissions (id, name, description) VALUES
(UUID(), 'view_donation', 'Melihat laporan donasi'),
(UUID(), 'edit_donation', 'Mengedit data donasi'),
(UUID(), 'create_event', 'Membuat kegiatan'),
(UUID(), 'approve_facility_report', 'Menyetujui laporan fasilitas'),
(UUID(), 'view_financial_report', 'Melihat laporan keuangan'),
(UUID(), 'manage_wakaf', 'Mengelola aset wakaf'),
(UUID(), 'post_social_media', 'Mengunggah ke media sosial'),
(UUID(), 'manage_rewards', 'Mengelola poin dan badge');

-- Contoh menghubungkan peran dengan izin
INSERT INTO role_has_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'super_admin' AND p.name IN (
    'view_donation', 'edit_donation', 'create_event', 'approve_facility_report',
    'view_financial_report', 'manage_wakaf', 'post_social_media', 'manage_rewards'
);

INSERT INTO role_has_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'dkm' AND p.name IN (
    'view_donation', 'create_event', 'approve_facility_report', 'manage_wakaf'
);

INSERT INTO role_has_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.name = 'volunteer' AND p.name IN ('create_event', 'approve_facility_report');