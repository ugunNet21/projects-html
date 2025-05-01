CREATE DATABASE db_penjaga;
USE db_penjaga;

-- table utama
-- Tabel User (Auth)
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password VARCHAR(255) NOT NULL,
    photo_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Roles (Contoh: Admin, Supervisor, Satpam, Client)
CREATE TABLE roles (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(50) UNIQUE NOT NULL, -- 'admin', 'satpam', 'client'
    guard_name VARCHAR(50) DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Permissions (Spatie-like)
CREATE TABLE permissions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(100) UNIQUE NOT NULL, -- 'view_dashboard', 'create_incident'
    guard_name VARCHAR(50) DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Role-User Pivot
CREATE TABLE model_has_roles (
    role_id CHAR(36) NOT NULL,
    model_type VARCHAR(255) NOT NULL, -- 'App\Models\User'
    model_id CHAR(36) NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- Tabel Permission-Role Pivot
CREATE TABLE role_has_permissions (
    permission_id CHAR(36) NOT NULL,
    role_id CHAR(36) NOT NULL,
    PRIMARY KEY (permission_id, role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- khusus penjaga

-- Tabel Instansi/Klien
CREATE TABLE clients (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    contact_person VARCHAR(255),
    contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Lokasi/Checkpoint
CREATE TABLE locations (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    client_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL, -- 'Pos Utama', 'Gudang A'
    geo_coordinates POINT NOT NULL, -- GIS (latitude, longitude)
    qr_code VARCHAR(255) UNIQUE, -- Untuk scan patroli
    is_critical BOOLEAN DEFAULT FALSE, -- Zona rawan?
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

-- Tabel Jadwal Shift
CREATE TABLE shifts (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(50) NOT NULL, -- 'Pagi (08:00-16:00)', 'Malam (22:00-06:00)'
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    client_id CHAR(36) NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

-- Tabel Penugasan Satpam
CREATE TABLE assignments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL, -- Satpam
    shift_id CHAR(36) NOT NULL,
    location_id CHAR(36) NOT NULL,
    date DATE NOT NULL,
    status ENUM('pending', 'ongoing', 'completed') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shift_id) REFERENCES shifts(id),
    FOREIGN KEY (location_id) REFERENCES locations(id)
);

-- Tabel Patroli
CREATE TABLE patrols (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    assignment_id CHAR(36) NOT NULL,
    checkpoint_id CHAR(36) NOT NULL,
    check_in TIMESTAMP NULL, -- Waktu scan QR
    check_out TIMESTAMP NULL,
    notes TEXT,
    photo_url VARCHAR(255), -- Bukti patroli
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (checkpoint_id) REFERENCES locations(id)
);

-- Tabel Insiden
CREATE TABLE incidents (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    assignment_id CHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL, -- 'Pencurian', 'Kebakaran'
    description TEXT,
    severity ENUM('low', 'medium', 'high') DEFAULT 'medium',
    status ENUM('reported', 'processed', 'resolved') DEFAULT 'reported',
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

-- Tabel Bukti Insiden (Foto/Video)
CREATE TABLE incident_attachments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    incident_id CHAR(36) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_type ENUM('image', 'video') NOT NULL,
    FOREIGN KEY (incident_id) REFERENCES incidents(id) ON DELETE CASCADE
);