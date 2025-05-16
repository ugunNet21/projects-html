-- 1. Users
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    email_verified_at TIMESTAMP NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);

-- 2. Roles (UUID version of Spatie roles)
CREATE TABLE roles (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);

-- 3. Permissions (UUID version of Spatie permissions)
CREATE TABLE permissions (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);

-- 4. Model Has Roles
CREATE TABLE model_has_roles (
    role_id CHAR(36) NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id CHAR(36) NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 5. Model Has Permissions
CREATE TABLE model_has_permissions (
    permission_id CHAR(36) NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id CHAR(36) NOT NULL,
    PRIMARY KEY (permission_id, model_id, model_type),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
);

-- 6. Role Has Permissions
CREATE TABLE role_has_permissions (
    permission_id CHAR(36) NOT NULL,
    role_id CHAR(36) NOT NULL,
    PRIMARY KEY (permission_id, role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 7. Masjid Profile
CREATE TABLE masjids (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100),
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    description TEXT,
    photo_url VARCHAR(255),
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);

-- 8. Jadwal Sholat
CREATE TABLE prayer_times (
    id CHAR(36) PRIMARY KEY,
    masjid_id CHAR(36),
    date DATE,
    subuh TIME,
    dzuhur TIME,
    ashar TIME,
    maghrib TIME,
    isya TIME,
    FOREIGN KEY (masjid_id) REFERENCES masjids(id) ON DELETE CASCADE
);

-- 9. Kegiatan Masjid
CREATE TABLE events (
    id CHAR(36) PRIMARY KEY,
    masjid_id CHAR(36),
    title VARCHAR(255),
    description TEXT,
    start_time DATETIME,
    end_time DATETIME,
    location VARCHAR(255),
    photo_url VARCHAR(255),
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (masjid_id) REFERENCES masjids(id) ON DELETE CASCADE
);

-- 10. Kajian & Ceramah
CREATE TABLE sermons (
    id CHAR(36) PRIMARY KEY,
    masjid_id CHAR(36),
    title VARCHAR(255),
    speaker VARCHAR(100),
    date DATETIME,
    video_url VARCHAR(255),
    audio_url VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (masjid_id) REFERENCES masjids(id) ON DELETE CASCADE
);

-- 11. Donasi (Infaq, Zakat, Wakaf)
CREATE TABLE donations (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    masjid_id CHAR(36),
    amount DECIMAL(15,2),
    type ENUM('infaq', 'zakat', 'wakaf'),
    payment_method VARCHAR(50),
    status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
    proof_url VARCHAR(255),
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (masjid_id) REFERENCES masjids(id) ON DELETE CASCADE
);

-- 12. Keuangan Masjid (Laporan)
CREATE TABLE financial_reports (
    id CHAR(36) PRIMARY KEY,
    masjid_id CHAR(36),
    title VARCHAR(255),
    type ENUM('income', 'expense'),
    amount DECIMAL(15,2),
    description TEXT,
    report_date DATE,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (masjid_id) REFERENCES masjids(id) ON DELETE CASCADE
);

-- 13. Kematian / Takziyah
CREATE TABLE obituaries (
    id CHAR(36) PRIMARY KEY,
    masjid_id CHAR(36),
    name VARCHAR(100),
    date_of_death DATE,
    burial_location VARCHAR(255),
    family_contact VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (masjid_id) REFERENCES masjids(id) ON DELETE CASCADE
);
