-- Database Creation
CREATE DATABASE cinema_system;
USE cinema_system;

-- Tabel Users (pengguna: pelanggan, admin, staff)
CREATE TABLE users (
    user_id BINARY(16) PRIMARY KEY, -- UUID stored as BINARY(16) for efficiency
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Hashed password
    full_name VARCHAR(100) NOT NULL,
    role ENUM('customer', 'admin', 'staff') NOT NULL DEFAULT 'customer',
    phone_number VARCHAR(20),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
);

-- Tabel Cinemas (lokasi bioskop)
CREATE TABLE cinemas (
    cinema_id BINARY(16) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_city (city)
);

-- Tabel Studios (studio di dalam bioskop)
CREATE TABLE studios (
    studio_id BINARY(16) PRIMARY KEY,
    cinema_id BINARY(16) NOT NULL,
    name VARCHAR(50) NOT NULL, -- e.g., "Studio 1", "IMAX"
    type ENUM('regular', '3D', '4DX', 'IMAX', 'VIP') NOT NULL DEFAULT 'regular',
    capacity INT NOT NULL, -- Total seats
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cinema_id) REFERENCES cinemas(cinema_id) ON DELETE CASCADE,
    INDEX idx_cinema_id (cinema_id)
);

-- Tabel Movies (informasi film)
CREATE TABLE movies (
    movie_id BINARY(16) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    synopsis TEXT,
    duration_minutes INT NOT NULL,
    genre VARCHAR(100), -- e.g., "Action, Sci-Fi"
    rating ENUM('SU', '13+', '17+', '21+') NOT NULL,
    release_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_title (title)
);

-- Tabel Showtimes (jadwal tayang)
CREATE TABLE showtimes (
    showtime_id BINARY(16) PRIMARY KEY,
    movie_id BINARY(16) NOT NULL,
    studio_id BINARY(16) NOT NULL,
    showtime_datetime DATETIME NOT NULL,
    ticket_price DECIMAL(10, 2) NOT NULL, -- Price in IDR
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    FOREIGN KEY (studio_id) REFERENCES studios(studio_id) ON DELETE CASCADE,
    INDEX idx_movie_id (movie_id),
    INDEX idx_studio_id (studio_id),
    INDEX idx_showtime_datetime (showtime_datetime)
);

-- Tabel Seats (kursi di studio)
CREATE TABLE seats (
    seat_id BINARY(16) PRIMARY KEY,
    studio_id BINARY(16) NOT NULL,
    seat_number VARCHAR(10) NOT NULL, -- e.g., "A1", "B12"
    seat_type ENUM('regular', 'premium', 'accessible') NOT NULL DEFAULT 'regular',
    is_active BOOLEAN DEFAULT TRUE, -- For maintenance purposes
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (studio_id) REFERENCES studios(studio_id) ON DELETE CASCADE,
    UNIQUE (studio_id, seat_number),
    INDEX idx_studio_id (studio_id)
);

-- Tabel Tickets (tiket yang dibeli)
CREATE TABLE tickets (
    ticket_id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    showtime_id BINARY(16) NOT NULL,
    seat_id BINARY(16) NOT NULL,
    purchase_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'confirmed', 'cancelled', 'used') NOT NULL DEFAULT 'pending',
    qr_code VARCHAR(255), -- Store QR code identifier or URL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (showtime_id) REFERENCES showtimes(showtime_id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seats(seat_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_showtime_id (showtime_id)
);

-- Tabel Payments (pembayaran tiket)
CREATE TABLE payments (
    payment_id BINARY(16) PRIMARY KEY,
    ticket_id BINARY(16) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('credit_card', 'bank_transfer', 'digital_wallet', 'cash') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255), -- From payment gateway
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id)
);

-- Tabel Promotions (promo atau diskon)
CREATE TABLE promotions (
    promotion_id BINARY(16) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_percentage DECIMAL(5, 2), -- e.g., 10.00 for 10%
    valid_from DATETIME NOT NULL,
    valid_until DATETIME NOT NULL,
    max_usage INT, -- Maximum times promo can be used
    current_usage INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code)
);

-- Tabel Ticket_Promotions (relasi tiket dengan promo)
CREATE TABLE ticket_promotions (
    ticket_id BINARY(16) NOT NULL,
    promotion_id BINARY(16) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ticket_id, promotion_id),
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE
);