-- Task 3: Implement Indexes for Optimization
-- ALX Airbnb Database Module

-- ==============================================
-- PERFORMANCE ANALYSIS: BEFORE ADDING INDEXES
-- ==============================================

-- Measure query performance BEFORE adding indexes
-- These EXPLAIN ANALYZE statements will show baseline performance

-- 1. User login query performance (before index)
EXPLAIN ANALYZE SELECT * FROM User WHERE email = 'user@example.com';

-- 2. Property search by location performance (before index)
EXPLAIN ANALYZE SELECT * FROM Property WHERE location = 'New York';

-- 3. Property search by price range performance (before index)
EXPLAIN ANALYZE SELECT * FROM Property WHERE pricepernight BETWEEN 100 AND 300;

-- 4. Booking date range query performance (before index)
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- 5. Reviews by property performance (before index)
EXPLAIN ANALYZE SELECT * FROM Review WHERE property_id = 123;

-- 6. Booking by user performance (before index)
EXPLAIN ANALYZE SELECT * FROM Booking WHERE user_id = 456;

-- 7. Payment by booking performance (before index)
EXPLAIN ANALYZE SELECT * FROM Payment WHERE booking_id = 789;

-- 8. Complex join query performance (before index)
EXPLAIN ANALYZE SELECT p.name, b.start_date, b.end_date, u.first_name, u.last_name
FROM Property p
JOIN Booking b ON p.property_id = b.property_id
JOIN User u ON b.user_id = u.user_id
WHERE p.location = 'California' AND b.start_date >= '2024-06-01';

-- ==============================================
-- INDEX CREATION
-- ==============================================

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

-- ==============================================
-- PERFORMANCE ANALYSIS: AFTER ADDING INDEXES
-- ==============================================

-- Measure query performance AFTER adding indexes
-- These EXPLAIN ANALYZE statements will show improved performance

-- 1. User login query performance (after index)
EXPLAIN ANALYZE SELECT * FROM User WHERE email = 'user@example.com';

-- 2. Property search by location performance (after index)
EXPLAIN ANALYZE SELECT * FROM Property WHERE location = 'New York';

-- 3. Property search by price range performance (after index)
EXPLAIN ANALYZE SELECT * FROM Property WHERE pricepernight BETWEEN 100 AND 300;

-- 4. Booking date range query performance (after index)
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- 5. Reviews by property performance (after index)
EXPLAIN ANALYZE SELECT * FROM Review WHERE property_id = 123;

-- 6. Booking by user performance (after index)
EXPLAIN ANALYZE SELECT * FROM Booking WHERE user_id = 456;

-- 7. Payment by booking performance (after index)
EXPLAIN ANALYZE SELECT * FROM Payment WHERE booking_id = 789;

-- 8. Complex join query performance (after index)
EXPLAIN ANALYZE SELECT p.name, b.start_date, b.end_date, u.first_name, u.last_name
FROM Property p
JOIN Booking b ON p.property_id = b.property_id
JOIN User u ON b.user_id = u.user_id
WHERE p.location = 'California' AND b.start_date >= '2024-06-01';

-- ==============================================
-- ADDITIONAL PERFORMANCE TESTING QUERIES
-- ==============================================

-- Test composite index performance
EXPLAIN ANALYZE SELECT * FROM Property 
WHERE location = 'Miami' AND pricepernight BETWEEN 150 AND 250;

-- Test partial index performance for active bookings
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE status = 'confirmed' AND start_date >= CURRENT_DATE;

-- Test text search index performance
EXPLAIN ANALYZE SELECT * FROM Property 
WHERE to_tsvector('english', name) @@ to_tsquery('english', 'luxury');

-- Test case-insensitive email search
EXPLAIN ANALYZE SELECT * FROM User WHERE LOWER(email) = LOWER('User@Example.com');

-- Test booking user status date composite index
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE user_id = 100 AND status = 'confirmed' AND start_date >= '2024-01-01';

-- Test high-value booking partial index
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE total_price > 100 AND start_date >= CURRENT_DATE - INTERVAL '1 year';

-- ==============================================
-- INDEX MAINTENANCE AND MONITORING
-- ==============================================

-- Show index usage analysis query
-- Use this query to monitor index usage after implementation
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch,
    idx_blks_read,
    idx_blks_hit,
    ROUND((idx_blks_hit::float / NULLIF(idx_blks_hit + idx_blks_read, 0)) * 100, 2) as hit_ratio
FROM pg_stat_user_indexes
ORDER BY idx_tup_read DESC;

-- Query to check index sizes
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as table_size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Query to find unused indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_tup_read = 0 AND idx_tup_fetch = 0
ORDER BY schemaname, tablename, indexname;

-- Query to check table scan vs index scan ratios
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    CASE 
        WHEN seq_scan + idx_scan > 0 
        THEN ROUND((idx_scan::float / (seq_scan + idx_scan)) * 100, 2) 
        ELSE 0 
    END as index_usage_ratio
FROM pg_stat_user_tables
ORDER BY index_usage_ratio ASC;

-- ==============================================
-- PERFORMANCE COMPARISON SUMMARY
-- ==============================================

-- To compare performance before and after indexes:
-- 1. Run the EXPLAIN ANALYZE queries in the "BEFORE" section
-- 2. Note the execution times and costs
-- 3. Create the indexes
-- 4. Run the EXPLAIN ANALYZE queries in the "AFTER" section
-- 5. Compare execution times, costs, and query plans

-- Expected improvements:
-- - Reduced execution time for indexed queries
-- - Lower cost values in query plans
-- - Index scans instead of sequential scans
-- - Faster JOIN operations due to foreign key indexes
-- - Better performance for WHERE clauses on indexed columns

-- Monitor these metrics:
-- - Total runtime (decreased)
-- - Planning time (may increase slightly)
-- - Actual time per loop (decreased)
-- - Rows processed (should be more selective)
-- - Buffers hit/read ratios (improved cache usage)