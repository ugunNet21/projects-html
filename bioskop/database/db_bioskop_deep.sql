-- Enable UUID functions
SET GLOBAL log_bin_trust_function_creators = 1;

-- Create database
CREATE DATABASE IF NOT EXISTS cinema_management_system;
USE cinema_management_system;

-- Enum tables for type safety
CREATE TABLE user_roles (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100)
);

CREATE TABLE movie_ratings (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(5) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE seat_types (
    id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL UNIQUE,
    price_multiplier DECIMAL(3,2) DEFAULT 1.00
);

-- Main entity tables with UUIDs
CREATE TABLE users (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    role_id TINYINT UNSIGNED,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(id)
);

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
    FOREIGN KEY (rating_id) REFERENCES movie_ratings(id)
);

CREATE TABLE cinemas (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    contact_phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE theaters (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    cinema_id BINARY(16) NOT NULL,
    name VARCHAR(50) NOT NULL,
    capacity SMALLINT UNSIGNED NOT NULL,
    screen_type ENUM('2D', '3D', 'IMAX', '4DX') DEFAULT '2D',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (cinema_id) REFERENCES cinemas(id),
    INDEX (cinema_id)
);

CREATE TABLE seats (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    theater_id BINARY(16) NOT NULL,
    row_char CHAR(1) NOT NULL,
    seat_number SMALLINT UNSIGNED NOT NULL,
    type_id TINYINT UNSIGNED,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (theater_id) REFERENCES theaters(id),
    FOREIGN KEY (type_id) REFERENCES seat_types(id),
    UNIQUE KEY (theater_id, row_char, seat_number),
    INDEX (theater_id)
);

-- Relationship tables
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
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (theater_id) REFERENCES theaters(id),
    INDEX (movie_id),
    INDEX (theater_id),
    INDEX (start_time)
);

CREATE TABLE bookings (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    user_id BINARY(16),
    screening_id BINARY(16) NOT NULL,
    booking_number VARCHAR(20) NOT NULL UNIQUE,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'paid', 'cancelled', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (screening_id) REFERENCES screenings(id),
    INDEX (user_id),
    INDEX (screening_id),
    INDEX (booking_number)
);

CREATE TABLE booked_seats (
    id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID())),
    booking_id BINARY(16) NOT NULL,
    seat_id BINARY(16) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seats(id),
    UNIQUE KEY (booking_id, seat_id),
    INDEX (booking_id),
    INDEX (seat_id)
);

-- Payment system
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
    FOREIGN KEY (booking_id) REFERENCES bookings(id),
    INDEX (booking_id),
    INDEX (transaction_id)
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
AND (b.id IS NULL OR b.status IN ('cancelled'));