-- =====================================================
-- ALX Airbnb Database Module - Aggregations and Window Functions
-- File: aggregations_and_window_functions.sql
-- Purpose: Demonstrate SQL aggregation functions and window functions
-- =====================================================

-- Task 1: Aggregation - Total number of bookings made by each user
-- Using COUNT function with GROUP BY clause
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(b.total_price), 0) AS total_spent,
    COALESCE(AVG(b.total_price), 0) AS average_booking_value
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
ORDER BY 
    total_bookings DESC, total_spent DESC;

-- Task 2: Window Functions - Rank properties by total number of bookings
-- Using ROW_NUMBER and RANK window functions
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    -- ROW_NUMBER: Assigns unique sequential numbers (no ties)
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_number_rank,
    -- RANK: Assigns same rank to tied values, skips subsequent ranks
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_with_gaps,
    -- DENSE_RANK: Assigns same rank to tied values, no gaps in ranking
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC, p.property_id;

-- Additional Advanced Aggregation Examples

-- Example 1: Detailed booking statistics by property
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    AVG(b.total_price) AS avg_booking_value,
    MIN(b.total_price) AS min_booking_value,
    MAX(b.total_price) AS max_booking_value,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.end_date) AS last_booking_date
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
HAVING 
    COUNT(b.booking_id) > 0
ORDER BY 
    total_revenue DESC;

-- Example 2: Monthly booking trends
SELECT 
    YEAR(b.start_date) AS booking_year,
    MONTH(b.start_date) AS booking_month,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    AVG(b.total_price) AS avg_booking_value,
    COUNT(DISTINCT b.user_id) AS unique_users,
    COUNT(DISTINCT b.property_id) AS unique_properties
FROM 
    Booking b
GROUP BY 
    YEAR(b.start_date), MONTH(b.start_date)
ORDER BY 
    booking_year DESC, booking_month DESC;

-- Advanced Window Function Examples

-- Example 3: Running totals and moving averages
SELECT 
    b.booking_id,
    b.user_id,
    b.property_id,
    b.start_date,
    b.total_price,
    -- Running total of booking values
    SUM(b.total_price) OVER (
        ORDER BY b.start_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    -- Moving average of last 3 bookings
    AVG(b.total_price) OVER (
        ORDER BY b.start_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_bookings,
    -- Ranking by booking value within each property
    RANK() OVER (
        PARTITION BY b.property_id 
        ORDER BY b.total_price DESC
    ) AS price_rank_within_property
FROM 
    Booking b
ORDER BY 
    b.start_date;

-- Example 4: Percentile and distribution analysis
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    -- Percentile ranks
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) AS booking_percentile,
    PERCENT_RANK() OVER (ORDER BY p.pricepernight) AS price_percentile,
    -- Quartiles
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) AS booking_quartile,
    NTILE(4) OVER (ORDER BY p.pricepernight) AS price_quartile
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;

-- Example 5: Lag and Lead functions for comparative analysis
SELECT 
    b.booking_id,
    b.user_id,
    b.property_id,
    b.start_date,
    b.total_price,
    -- Previous booking price for same user
    LAG(b.total_price, 1) OVER (
        PARTITION BY b.user_id 
        ORDER BY b.start_date
    ) AS previous_booking_price,
    -- Next booking price for same user
    LEAD(b.total_price, 1) OVER (
        PARTITION BY b.user_id 
        ORDER BY b.start_date
    ) AS next_booking_price,
    -- Difference from previous booking
    b.total_price - LAG(b.total_price, 1) OVER (
        PARTITION BY b.user_id 
        ORDER BY b.start_date
    ) AS price_change_from_previous
FROM 
    Booking b
ORDER BY 
    b.user_id, b.start_date;

-- Example 6: Complex window function with multiple partitions
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    -- Rank within location
    RANK() OVER (
        PARTITION BY p.location 
        ORDER BY COUNT(b.booking_id) DESC
    ) AS rank_in_location,
    -- Rank within price range
    RANK() OVER (
        PARTITION BY 
            CASE 
                WHEN p.pricepernight <= 100 THEN 'Budget'
                WHEN p.pricepernight <= 200 THEN 'Mid-range'
                ELSE 'Premium'
            END
        ORDER BY COUNT(b.booking_id) DESC
    ) AS rank_in_price_category,
    -- Property's share of total bookings in location
    ROUND(
        COUNT(b.booking_id) * 100.0 / 
        SUM(COUNT(b.booking_id)) OVER (PARTITION BY p.location), 
        2
    ) AS location_market_share_percent
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    p.location, rank_in_location;

-- Example 7: First and last value functions
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.total_price,
    -- First booking details for each user
    FIRST_VALUE(b.total_price) OVER (
        PARTITION BY u.user_id 
        ORDER BY b.start_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_booking_price,
    -- Last booking details for each user
    LAST_VALUE(b.total_price) OVER (
        PARTITION BY u.user_id 
        ORDER BY b.start_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_booking_price,
    -- Difference between first and current booking
    b.total_price - FIRST_VALUE(b.total_price) OVER (
        PARTITION BY u.user_id 
        ORDER BY b.start_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS price_change_from_first
FROM 
    User u
INNER JOIN 
    Booking b ON u.user_id = b.user_id
ORDER BY 
    u.user_id, b.start_date;