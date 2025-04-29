-- bis gunakan admin-bioskop-deep-gr-screen, admin-bioskop-deep-dbdeep-keren, admin-bioskop-deep-update-grok

-- Enable UUID functions for generating unique identifiers
SET GLOBAL log_bin_trust_function_creators = 1;

-- Create database for cinema management system
CREATE DATABASE IF NOT EXISTS cinema_management_system;
USE cinema_management_system;

-- Enum tables for type safety
-- Stores different user roles (e.g., admin, customer, staff)
CREATE TABLE user_roles (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100),
    COMMENT 'Defines user roles for access control'
);

-- Stores movie rating categories (e.g., PG, R)
CREATE TABLE movie_ratings (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    COMMENT 'Defines movie ratings for age restrictions'
);

-- Stores seat types with dynamic pricing multipliers
CREATE TABLE seat_types (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL UNIQUE,
    price_multiplier DECIMAL(3,2) DEFAULT 1.00,
    COMMENT 'Defines seat types (e.g., regular, VIP) with price adjustments'
);

-- Stores promotional offers and discounts
CREATE TABLE promotions (
    promotion_id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_percentage DECIMAL(5,2), -- e.g., 10.00 for 10% discount
    valid_from DATETIME NOT NULL,
    valid_until DATETIME NOT NULL,
    max_usage INT, -- Maximum times promo can be used
    current_usage INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    COMMENT 'Stores promotional codes and discounts'
);

-- Main entity tables with UUIDs
-- Stores user information with role assignment
CREATE TABLE users (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE, -- Added for age verification or personalization
    role_id TINYINT UNSIGNED,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(id),
    INDEX idx_email (email),
    COMMENT 'Stores user data including customers, admins, and staff'
);

-- Stores movie information
CREATE TABLE movies (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    title VARCHAR(100) NOT NULL,
    description TEXT,
    duration_minutes SMALLINT UNSIGNED NOT NULL,
    release_date DATE,
    rating_id TINYINT UNSIGNED,
    poster_url VARCHAR(255),
    trailer_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (rating_id) REFERENCES movie_ratings(id),
    INDEX idx_title (title),
    COMMENT 'Stores movie details including title, duration, and rating'
);

-- Stores cinema locations
CREATE TABLE cinemas (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL, -- Added for location-based search
    contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_city (city),
    COMMENT 'Stores cinema locations and contact information'
);

-- Stores theaters within cinemas
CREATE TABLE theaters (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    cinema_id BINARY(16) NOT NULL,
    name VARCHAR(50) NOT NULL,
    capacity SMALLINT UNSIGNED NOT NULL,
    screen_type ENUM('2D', '3D', 'IMAX', '4DX') DEFAULT '2D',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cinema_id) REFERENCES cinemas(id) ON DELETE CASCADE,
    INDEX idx_cinema_id (cinema_id),
    COMMENT 'Stores theater details within a cinema'
);

-- Stores seat information within theaters
CREATE TABLE seats (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    theater_id BINARY(16) NOT NULL,
    row_char CHAR(1) NOT NULL,
    seat_number SMALLINT UNSIGNED NOT NULL,
    type_id TINYINT UNSIGNED,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (theater_id) REFERENCES theaters(id) ON DELETE CASCADE,
    FOREIGN KEY (type_id) REFERENCES seat_types(id),
    UNIQUE KEY uk_seat (theater_id, row_char, seat_number),
    INDEX idx_theater_id (theater_id),
    COMMENT 'Stores seat details with row and number'
);

-- Relationship tables
-- Stores movie screening schedules
CREATE TABLE screenings (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    movie_id BINARY(16) NOT NULL,
    theater_id BINARY(16) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
    FOREIGN KEY (theater_id) REFERENCES theaters(id) ON DELETE CASCADE,
    INDEX idx_movie_id (movie_id),
    INDEX idx_theater_id (theater_id),
    INDEX idx_start_time (start_time),
    COMMENT 'Stores movie screening schedules and pricing'
);

-- Stores booking information
CREATE TABLE bookings (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    user_id BINARY(16),
    screening_id BINARY(16) NOT NULL,
    booking_number VARCHAR(20) NOT NULL UNIQUE,
    total_amount DECIMAL(10,2) NOT NULL,
    qr_code VARCHAR(255), -- Added for digital ticket verification
    status ENUM('pending', 'paid', 'cancelled', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (screening_id) REFERENCES screenings(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_screening_id (screening_id),
    INDEX idx_booking_number (booking_number),
    COMMENT 'Stores booking details with unique booking number and QR code'
);

-- Stores individual booked seats
CREATE TABLE booked_seats (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    booking_id BINARY(16) NOT NULL,
    seat_id BINARY(16) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seats(id) ON DELETE CASCADE,
    UNIQUE KEY uk_booked_seat (booking_id, seat_id),
    INDEX idx_booking_id (booking_id),
    INDEX idx_seat_id (seat_id),
    COMMENT 'Stores individual seat bookings'
);

-- Stores relationships between bookings and promotions
CREATE TABLE booking_promotions (
    booking_id BINARY(16) NOT NULL,
    promotion_id BINARY(16) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, promotion_id),
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE,
    COMMENT 'Links bookings to applied promotions'
);

-- Payment system
-- Stores payment information
CREATE TABLE payments (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    booking_id BINARY(16) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method ENUM('cash', 'credit_card', 'debit_card', 'e_wallet', 'bank_transfer') NOT NULL,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(100),
    payment_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_booking_id (booking_id),
    INDEX idx_transaction_id (transaction_id),
    COMMENT 'Stores payment details for bookings'
);

-- View for available seats
CREATE VIEW available_seats AS
SELECT s.*, sc.id AS screening_id, sc.start_time
FROM seats s
JOIN theaters t ON s.theater_id = t.id
JOIN screenings sc ON sc.theater_id = t.id
LEFT JOIN booked_seats bs ON bs.seat_id = s.id
LEFT JOIN bookings b ON bs.booking_id = b.id AND b.screening_id = sc.id
WHERE s.is_active = TRUE 
AND (b.id IS NULL OR b.status IN ('cancelled'))
COMMENT 'View to show available seats for screenings';