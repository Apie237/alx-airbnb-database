-- =====================================================
-- Airbnb Database Schema Creation Script
-- Version: 1.0
-- Author: ALX Student
-- Description: Complete database schema for Airbnb-like application
-- =====================================================

-- Enable UUID extension for PostgreSQL (comment out if using MySQL)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USER TABLE
-- =====================================================
CREATE TABLE User (
    user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_phone_format CHECK (phone_number IS NULL OR phone_number REGEXP '^[+]?[0-9\s\-\(\)]{10,}$')
);

-- =====================================================
-- 2. PROPERTY TABLE
-- =====================================================
CREATE TABLE Property (
    property_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    host_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_property_host 
        FOREIGN KEY (host_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_price_positive CHECK (price_per_night > 0),
    CONSTRAINT chk_name_length CHECK (CHAR_LENGTH(name) >= 3)
);

-- =====================================================
-- 3. BOOKING TABLE
-- =====================================================
CREATE TABLE Booking (
    booking_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_booking_property 
        FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_booking_user 
        FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_booking_dates CHECK (start_date < end_date),
    CONSTRAINT chk_booking_future CHECK (start_date >= CURDATE()),
    CONSTRAINT chk_total_price_positive CHECK (total_price > 0)
);

-- =====================================================
-- 4. PAYMENT TABLE
-- =====================================================
CREATE TABLE Payment (
    payment_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    booking_id CHAR(36) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    
    -- Foreign Keys
    CONSTRAINT fk_payment_booking 
        FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_payment_amount_positive CHECK (amount > 0)
);

-- =====================================================
-- 5. REVIEW TABLE
-- =====================================================
CREATE TABLE Review (
    review_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_review_property 
        FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    
    -- Unique constraint to prevent multiple reviews from same user for same property
    CONSTRAINT uk_user_property_review UNIQUE (user_id, property_id)
);

-- =====================================================
-- 6. MESSAGE TABLE
-- =====================================================
CREATE TABLE Message (
    message_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    sender_id CHAR(36) NOT NULL,
    recipient_id CHAR(36) NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_message_sender 
        FOREIGN KEY (sender_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_message_recipient 
        FOREIGN KEY (recipient_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_different_users CHECK (sender_id != recipient_id),
    CONSTRAINT chk_message_not_empty CHECK (CHAR_LENGTH(TRIM(message_body)) > 0)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- User table indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Property table indexes
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price ON Property(price_per_night);
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Booking table indexes
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Payment table indexes
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_date ON Payment(payment_date);
CREATE INDEX idx_payment_method ON Payment(payment_method);

-- Review table indexes
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Message table indexes
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);

-- =====================================================
-- COMPOSITE INDEXES FOR COMPLEX QUERIES
-- =====================================================

-- Find properties by location and price range
CREATE INDEX idx_property_location_price ON Property(location, price_per_night);

-- Find bookings by property and date range
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);

-- Find reviews by property and rating
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- Find messages between users
CREATE INDEX idx_message_users ON Message(sender_id, recipient_id, sent_at);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- =====================================================

-- Trigger for User table
DELIMITER //
CREATE TRIGGER trg_user_updated_at
    BEFORE UPDATE ON User
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END//

-- Trigger for Property table
CREATE TRIGGER trg_property_updated_at
    BEFORE UPDATE ON Property
    FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for property details with host information
CREATE VIEW v_property_details AS
SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.price_per_night,
    u.first_name AS host_first_name,
    u.last_name AS host_last_name,
    u.email AS host_email,
    p.created_at
FROM Property p
JOIN User u ON p.host_id = u.user_id;

-- View for booking details
CREATE VIEW v_booking_details AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.name AS property_name,
    p.location,
    CONCAT(guest.first_name, ' ', guest.last_name) AS guest_name,
    CONCAT(host.first_name, ' ', host.last_name) AS host_name
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN User guest ON b.user_id = guest.user_id
JOIN User host ON p.host_id = host.user_id;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Procedure to check booking availability
DELIMITER //
CREATE PROCEDURE CheckBookingAvailability(
    IN p_property_id CHAR(36),
    IN p_start_date DATE,
    IN p_end_date DATE,
    OUT p_available BOOLEAN
)
BEGIN
    DECLARE conflict_count INT DEFAULT 0;
    
    SELECT COUNT(*) INTO conflict_count
    FROM Booking
    WHERE property_id = p_property_id
      AND status IN ('confirmed', 'pending')
      AND (
          (start_date <= p_start_date AND end_date > p_start_date)
          OR (start_date < p_end_date AND end_date >= p_end_date)
          OR (start_date >= p_start_date AND end_date <= p_end_date)
      );
    
    SET p_available = (conflict_count = 0);
END//
DELIMITER ;

-- =====================================================
-- INITIAL ADMIN USER CREATION
-- =====================================================

-- Create default admin user (password should be hashed in real implementation)
INSERT INTO User (user_id, first_name, last_name, email, password_hash, role)
VALUES (
    UUID(),
    'System',
    'Administrator',
    'admin@airbnb.local',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- "password"
    'admin'
);

-- =====================================================
-- PERFORMANCE AND MONITORING SETUP
-- =====================================================

-- Enable query logging for performance monitoring
-- SET GLOBAL general_log = 'ON';
-- SET GLOBAL slow_query_log = 'ON';
-- SET GLOBAL long_query_time = 2;

-- =====================================================
-- SCRIPT COMPLETION MESSAGE
-- =====================================================
SELECT 'Airbnb Database Schema Created Successfully!' as Status;