-- Task 4: Optimize Complex Queries
-- ALX Airbnb Database Module

-- INITIAL QUERY (Before Optimization)
-- This query retrieves all bookings with user details, property details, and payment details
-- Note: This is the initial version that may have performance issues

SELECT 
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    b.created_at AS booking_created,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created,
    p.updated_at AS property_updated,
    
    -- Host details
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    h.phone_number AS host_phone,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method,
    
    -- Additional calculated fields
    (b.end_date - b.start_date) AS booking_duration,
    (SELECT AVG(rating) FROM Review r WHERE r.property_id = p.property_id) AS avg_property_rating,
    (SELECT COUNT(*) FROM Review r WHERE r.property_id = p.property_id) AS total_reviews,
    (SELECT COUNT(*) FROM Booking b2 WHERE b2.user_id = u.user_id) AS user_total_bookings

FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- OPTIMIZED QUERY (After Analysis and Refactoring)
-- This version addresses performance issues identified through EXPLAIN ANALYZE

-- Step 1: Create a CTE for property statistics to avoid repeated subqueries
WITH property_stats AS (
    SELECT 
        property_id,
        AVG(rating) AS avg_rating,
        COUNT(*) AS total_reviews
    FROM Review
    GROUP BY property_id
),
user_stats AS (
    SELECT 
        user_id,
        COUNT(*) AS total_bookings
    FROM Booking
    GROUP BY user_id
)

SELECT 
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    b.created_at AS booking_created,
    
    -- User details (only essential fields)
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    
    -- Property details (only essential fields)
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    -- Host details (only essential fields)
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method,
    
    -- Calculated fields from CTEs
    (b.end_date - b.start_date) AS booking_duration,
    COALESCE(ps.avg_rating, 0) AS avg_property_rating,
    COALESCE(ps.total_reviews, 0) AS total_reviews,
    COALESCE(us.total_bookings, 0) AS user_total_bookings

FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
LEFT JOIN property_stats ps ON p.property_id = ps.property_id
LEFT JOIN user_stats us ON u.user_id = us.user_id
ORDER BY b.created_at DESC;

-- ALTERNATIVE OPTIMIZED QUERY with pagination for large datasets
-- This version includes LIMIT and OFFSET for pagination

WITH property_stats AS (
    SELECT 
        property_id,
        AVG(rating) AS avg_rating,
        COUNT(*) AS total_reviews
    FROM Review
    GROUP BY property_id
),
user_stats AS (
    SELECT 
        user_id,
        COUNT(*) AS total_bookings
    FROM Booking
    GROUP BY user_id
)

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    u.first_name || ' ' || u.last_name AS guest_name,
    u.email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    h.first_name || ' ' || h.last_name AS host_name,
    pay.amount AS payment_amount,
    pay.payment_method,
    (b.end_date - b.start_date) AS booking_duration,
    ROUND(COALESCE(ps.avg_rating, 0), 2) AS avg_property_rating,
    COALESCE(ps.total_reviews, 0) AS total_reviews,
    COALESCE(us.total_bookings, 0) AS user_total_bookings

FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
LEFT JOIN property_stats ps ON p.property_id = ps.property_id
LEFT JOIN user_stats us ON u.user_id = us.user_id
WHERE b.created_at >= CURRENT_DATE - INTERVAL '1 year'  -- Filter for recent bookings
ORDER BY b.created_at DESC
LIMIT 100 OFFSET 0;

-- Query for specific date range (common use case)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name || ' ' || u.last_name AS guest_name,
    p.name AS property_name,
    p.location,
    pay.amount AS payment_amount,
    pay.payment_method

FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.start_date >= '2024-01-01' 
  AND b.start_date <= '2024-12-31'
  AND b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- Performance testing queries
-- Run these with EXPLAIN ANALYZE to measure performance

-- Test query 1: Simple booking lookup
EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.total_price, u.first_name, u.last_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
WHERE b.start_date >= '2024-01-01'
ORDER BY b.start_date DESC
LIMIT 10;

-- Test query 2: Complex aggregation
EXPLAIN ANALYZE
SELECT 
    p.property_id,
    p.name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    AVG(r.rating) AS avg_rating
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name
HAVING COUNT(b.booking_id) > 5
ORDER BY total_revenue DESC
LIMIT 20;