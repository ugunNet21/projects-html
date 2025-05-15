-- Membuat database
CREATE DATABASE whatsapp_clone;
USE whatsapp_clone;

-- Tabel users: menyimpan informasi pengguna
CREATE TABLE users (
    id BINARY(16) PRIMARY KEY, -- UUID disimpan sebagai binary untuk efisiensi
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    profile_picture VARCHAR(255),
    status TEXT,
    last_seen DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL -- Soft delete
);

-- Tabel roles: menyimpan role pengguna (inspired by Spatie)
CREATE TABLE roles (
    id BINARY(16) PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    guard_name VARCHAR(50) NOT NULL DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel permissions: menyimpan izin (inspired by Spatie)
CREATE TABLE permissions (
    id BINARY(16) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    guard_name VARCHAR(50) NOT NULL DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel model_has_roles: pivot untuk menghubungkan user dengan role
CREATE TABLE model_has_roles (
    role_id BINARY(16),
    model_id BINARY(16),
    model_type VARCHAR(50) NOT NULL DEFAULT 'user',
    PRIMARY KEY (role_id, model_id, model_type),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel model_has_permissions: pivot untuk izin langsung ke user
CREATE TABLE model_has_permissions (
    permission_id BINARY(16),
    model_id BINARY(16),
    model_type VARCHAR(50) NOT NULL DEFAULT 'user',
    PRIMARY KEY (permission_id, model_id, model_type),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel role_has_permissions: pivot untuk izin ke role
CREATE TABLE role_has_permissions (
    permission_id BINARY(16),
    role_id BINARY(16),
    PRIMARY KEY (permission_id, role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- Tabel chats: menyimpan metadata percakapan 1:1
CREATE TABLE chats (
    id BINARY(16) PRIMARY KEY,
    user1_id BINARY(16) NOT NULL,
    user2_id BINARY(16) NOT NULL,
    encryption_key TEXT, -- Metadata untuk end-to-end encryption
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (user1_id, user2_id)
);

-- Tabel messages: menyimpan pesan
CREATE TABLE messages (
    id BINARY(16) PRIMARY KEY,
    chat_id BINARY(16) NULL, -- Untuk chat 1:1
    group_id BINARY(16) NULL, -- Untuk chat grup
    sender_id BINARY(16) NOT NULL,
    content TEXT NOT NULL, -- Konten pesan (teks atau metadata terenkripsi)
    type ENUM('text', 'image', 'video', 'audio', 'document', 'location') NOT NULL,
    media_url VARCHAR(255), -- URL ke file media jika ada
    is_read BOOLEAN DEFAULT FALSE,
    delivered_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE SET NULL,
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE SET NULL,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel groups: menyimpan informasi grup
CREATE TABLE groups (
    id BINARY(16) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    group_picture VARCHAR(255),
    created_by BINARY(16) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel group_members: menyimpan anggota grup
CREATE TABLE group_members (
    group_id BINARY(16),
    user_id BINARY(16),
    role ENUM('admin', 'member') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel statuses: menyimpan status pengguna (mirip WhatsApp Status)
CREATE TABLE statuses (
    id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    content TEXT,
    type ENUM('text', 'image', 'video') NOT NULL,
    media_url VARCHAR(255),
    expires_at TIMESTAMP NOT NULL, -- Status kadaluarsa setelah 24 jam
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel status_views: menyimpan siapa yang melihat status
CREATE TABLE status_views (
    status_id BINARY(16),
    user_id BINARY(16),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (status_id, user_id),
    FOREIGN KEY (status_id) REFERENCES statuses(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabel settings: pengaturan privasi pengguna
CREATE TABLE settings (
    id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    last_seen_visibility ENUM('everyone', 'contacts', 'nobody') DEFAULT 'everyone',
    profile_picture_visibility ENUM('everyone', 'contacts', 'nobody') DEFAULT 'everyone',
    status_visibility ENUM('everyone', 'contacts', 'nobody') DEFAULT 'everyone',
    read_receipts BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (user_id)
);

-- Fungsi untuk menghasilkan UUID
DELIMITER //
CREATE FUNCTION uuid_to_bin(uuid CHAR(36))
RETURNS BINARY(16)
DETERMINISTIC
BEGIN
    RETURN UNHEX(REPLACE(uuid, '-', ''));
END //
DELIMITER ;

-- Contoh data awal untuk roles dan permissions
INSERT INTO roles (id, name, guard_name) VALUES 
(uuid_to_bin(UUID()), 'admin', 'web'),
(uuid_to_bin(UUID()), 'user', 'web');

INSERT INTO permissions (id, name, guard_name) VALUES 
(uuid_to_bin(UUID()), 'send_message', 'web'),
(uuid_to_bin(UUID()), 'create_group', 'web'),
(uuid_to_bin(UUID()), 'delete_message', 'web');

-- Contoh menghubungkan role dengan permission
INSERT INTO role_has_permissions (permission_id, role_id) 
SELECT p.id, r.id 
FROM permissions p, roles r 
WHERE p.name = 'send_message' AND r.name = 'user';