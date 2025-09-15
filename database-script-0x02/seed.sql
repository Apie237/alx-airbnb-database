-- =====================================================
-- Airbnb Database Seed Data Script
-- Version: 1.0
-- Author: ALX Student  
-- Description: Sample data insertion for Airbnb-like application
-- =====================================================

-- Clear existing data (if any) for clean seeding
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Message;
TRUNCATE TABLE Review; 
TRUNCATE TABLE Payment;
TRUNCATE TABLE Booking;
TRUNCATE TABLE Property;
TRUNCATE TABLE User;
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 1. SEED USER TABLE
-- =====================================================

INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Hosts
('550e8400-e29b-41d4-a716-446655440001', 'Alice', 'Johnson', 'alice.johnson@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1-555-0101', 'host', '2024-01-15 10:30:00'),
('550e8400-e29b-41d4-a716-446655440002', 'Bob', 'Smith', 'bob.smith@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1-555-0102', 'host', '2024-01-16 14:20:00'),
('550e8400-e29b-41d4-a716-446655440003', 'Carol', 'Davis', 'carol.davis@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1-555-0103', 'host', '2024-01-17 09:15:00'),
('550e8400-e29b-41d4-a716-446655440004', 'David', 'Wilson', 'david.wilson@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC')