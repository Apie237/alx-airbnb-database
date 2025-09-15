-- Task 3: Implement Indexes for Optimization
-- ALX Airbnb Database Module

-- Performance Analysis: Identify high-usage columns before indexing
-- Common query patterns that would benefit from indexing:
-- 1. User lookups by email (login functionality)
-- 2. Booking queries by date ranges
-- 3. Property searches by location
-- 4. Foreign key joins between tables
-- 5. Review queries by property
-- 6. Payment queries by booking

-- User Table Indexes
-- Index on email for login queries
CREATE INDEX idx_user_email ON User(email);

-- Index on role for filtering users by type
CREATE INDEX idx_user_role ON User(role);

-- Composite index on first_name and last_name for name searches
CREATE INDEX idx_user_name ON User(first_name, last_name);

-- Property Table Indexes
-- Index on location for property searches
CREATE INDEX idx_property_location ON Property(location);

-- Index on pricepernight for price range queries
CREATE INDEX idx_property_price ON Property(pricepernight);

-- Index on host_id for foreign key joins
CREATE INDEX idx_property_host_id ON Property(host_id);

-- Composite index on location and pricepernight for filtered searches
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- Booking Table Indexes
-- Index on user_id for foreign key joins
CREATE INDEX idx_booking_user_id ON Booking(user_id);

-- Index on property_id for foreign key joins
CREATE INDEX idx_booking_property_id ON Booking(property_id);

-- Composite index on start_date and end_date for date range queries
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);

-- Index on start_date for date-based queries and partitioning
CREATE INDEX idx_booking_start_date ON Booking(start_date);

-- Index on status for filtering bookings
CREATE INDEX idx_booking_status ON Booking(status);

-- Index on created_at for recent bookings queries
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Composite index for common booking queries
CREATE INDEX idx_booking_user_status_date ON Booking(user_id, status, start_date);

-- Review Table Indexes
-- Index on property_id for foreign key joins
CREATE INDEX idx_review_property_id ON Review(property_id);

-- Index on user_id for foreign key joins
CREATE INDEX idx_review_user_id ON Review(user_id);

-- Index on rating for filtering high-rated properties
CREATE INDEX idx_review_rating ON Review(rating);

-- Composite index on property_id and rating for property rating queries
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- Index on created_at for recent reviews
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Payment Table Indexes
-- Index on booking_id for foreign key joins
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);

-- Index on payment_date for date-based queries
CREATE INDEX idx_payment_date ON Payment(payment_date);

-- Index on payment_method for payment analysis
CREATE INDEX idx_payment_method ON Payment(payment_method);

-- Composite index on booking_id and payment_date
CREATE INDEX idx_payment_booking_date ON Payment(booking_id, payment_date);

-- Advanced Indexes

-- Partial index for active bookings only
CREATE INDEX idx_booking_active ON Booking(start_date, end_date) 
WHERE status = 'confirmed';

-- Partial index for recent high-value bookings
CREATE INDEX idx_booking_high_value ON Booking(total_price, start_date) 
WHERE total_price > 100 AND start_date >= CURRENT_DATE - INTERVAL '1 year';

-- Index for text search on property names (if using PostgreSQL)
CREATE INDEX idx_property_name_text ON Property USING gin(to_tsvector('english', name));

-- Index for text search on property descriptions
CREATE INDEX idx_property_description_text ON Property USING gin(to_tsvector('english', description));

-- Functional index for case-insensitive email searches
CREATE INDEX idx_user_email_lower ON User(LOWER(email));

-- Index for JSON columns (if using JSON data types)
-- CREATE INDEX idx_property_amenities ON Property USING gin(amenities);

-- Show index usage analysis query
-- Use this query to monitor index usage after implementation
/*
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch,
    idx_blks_read,
    idx_blks_hit
FROM pg_stat_user_indexes
ORDER BY idx_tup_read DESC;
*/

-- Query to check index sizes
/*
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
*/