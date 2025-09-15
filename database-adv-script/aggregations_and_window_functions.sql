-- Task 2: Apply Aggregations and Window Functions
-- ALX Airbnb Database Module

-- 1. Find the total number of bookings made by each user using COUNT and GROUP BY
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_amount_spent,
    AVG(b.total_price) AS average_booking_value,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.start_date) AS last_booking_date
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
WHERE u.role = 'guest'
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_bookings DESC, total_amount_spent DESC;

-- 2. Use window functions to rank properties based on total bookings
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    AVG(b.total_price) AS avg_booking_value,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_number_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_by_bookings,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank_by_bookings,
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS percent_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY total_bookings DESC;

-- 3. Advanced window functions - Running totals and moving averages
SELECT 
    b.booking_id,
    b.start_date,
    b.total_price,
    p.name AS property_name,
    u.first_name || ' ' || u.last_name AS guest_name,
    SUM(b.total_price) OVER (
        ORDER BY b.start_date 
        ROWS UNBOUNDED PRECEDING
    ) AS running_total_revenue,
    AVG(b.total_price) OVER (
        ORDER BY b.start_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_bookings,
    LAG(b.total_price, 1) OVER (ORDER BY b.start_date) AS previous_booking_price,
    LEAD(b.total_price, 1) OVER (ORDER BY b.start_date) AS next_booking_price
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
JOIN User u ON b.user_id = u.user_id
ORDER BY b.start_date;

-- 4. Partition window functions by property
SELECT 
    p.property_id,
    p.name,
    b.booking_id,
    b.start_date,
    b.total_price,
    u.first_name || ' ' || u.last_name AS guest_name,
    ROW_NUMBER() OVER (
        PARTITION BY p.property_id 
        ORDER BY b.start_date
    ) AS booking_sequence_for_property,
    RANK() OVER (
        PARTITION BY p.property_id 
        ORDER BY b.total_price DESC
    ) AS price_rank_within_property,
    FIRST_VALUE(b.total_price) OVER (
        PARTITION BY p.property_id 
        ORDER BY b.start_date
        ROWS UNBOUNDED PRECEDING
    ) AS first_booking_price,
    LAST_VALUE(b.total_price) OVER (
        PARTITION BY p.property_id 
        ORDER BY b.start_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_booking_price
FROM Property p
JOIN Booking b ON p.property_id = b.property_id
JOIN User u ON b.user_id = u.user_id
ORDER BY p.property_id, b.start_date;

-- 5. Monthly booking analysis with window functions
SELECT 
    DATE_TRUNC('month', b.start_date) AS booking_month,
    COUNT(*) AS monthly_bookings,
    SUM(b.total_price) AS monthly_revenue,
    AVG(b.total_price) AS avg_monthly_booking_value,
    LAG(COUNT(*), 1) OVER (ORDER BY DATE_TRUNC('month', b.start_date)) AS prev_month_bookings,
    LAG(SUM(b.total_price), 1) OVER (ORDER BY DATE_TRUNC('month', b.start_date)) AS prev_month_revenue,
    ROUND(
        (COUNT(*) - LAG(COUNT(*), 1) OVER (ORDER BY DATE_TRUNC('month', b.start_date))) * 100.0 / 
        NULLIF(LAG(COUNT(*), 1) OVER (ORDER BY DATE_TRUNC('month', b.start_date)), 0), 2
    ) AS booking_growth_percentage
FROM Booking b
GROUP BY DATE_TRUNC('month', b.start_date)
ORDER BY booking_month;