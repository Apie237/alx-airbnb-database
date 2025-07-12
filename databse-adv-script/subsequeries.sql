-- =====================================================
-- ALX Airbnb Database Module - Advanced SQL Subqueries
-- File: subqueries.sql
-- Purpose: Demonstrate correlated and non-correlated subqueries
-- =====================================================

-- Task 1: Non-correlated subquery - Find properties with average rating > 4.0
-- This subquery calculates the average rating for each property independently
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    p.host_id
FROM 
    Property p
WHERE 
    p.property_id IN (
        SELECT 
            r.property_id
        FROM 
            Review r
        GROUP BY 
            r.property_id
        HAVING 
            AVG(r.rating) > 4.0
    )
ORDER BY 
    p.property_id;

-- Alternative approach using EXISTS with subquery
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    p.host_id
FROM 
    Property p
WHERE 
    EXISTS (
        SELECT 1
        FROM Review r
        WHERE r.property_id = p.property_id
        GROUP BY r.property_id
        HAVING AVG(r.rating) > 4.0
    )
ORDER BY 
    p.property_id;

-- Task 2: Correlated subquery - Find users who have made more than 3 bookings
-- This subquery references the outer query's User table for each row
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.created_at
FROM 
    User u
WHERE 
    (
        SELECT COUNT(*)
        FROM Booking b
        WHERE b.user_id = u.user_id
    ) > 3
ORDER BY 
    u.user_id;

-- Additional Advanced Subquery Examples

-- Example 1: Scalar subquery - Properties with above-average price
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    ROUND(p.pricepernight - (
        SELECT AVG(pricepernight) 
        FROM Property
    ), 2) AS price_difference_from_average
FROM 
    Property p
WHERE 
    p.pricepernight > (
        SELECT AVG(pricepernight) 
        FROM Property
    )
ORDER BY 
    p.pricepernight DESC;

-- Example 2: Multiple column subquery - Properties in locations with high booking activity
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight
FROM 
    Property p
WHERE 
    p.location IN (
        SELECT 
            p2.location
        FROM 
            Property p2
        INNER JOIN 
            Booking b ON p2.property_id = b.property_id
        GROUP BY 
            p2.location
        HAVING 
            COUNT(b.booking_id) > 10
    )
ORDER BY 
    p.location, p.pricepernight;

-- Example 3: Nested subqueries - Users who booked the most expensive properties
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM 
    User u
WHERE 
    u.user_id IN (
        SELECT DISTINCT b.user_id
        FROM Booking b
        WHERE b.property_id IN (
            SELECT p.property_id
            FROM Property p
            WHERE p.pricepernight >= (
                SELECT AVG(pricepernight) * 1.5
                FROM Property
            )
        )
    )
ORDER BY 
    u.user_id;

-- Example 4: Correlated subquery with EXISTS - Properties with recent reviews
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight
FROM 
    Property p
WHERE 
    EXISTS (
        SELECT 1
        FROM Review r
        WHERE r.property_id = p.property_id
        AND r.created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
    )
ORDER BY 
    p.property_id;

-- Example 5: Subquery with aggregation - Users with above-average spending
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    (
        SELECT SUM(b.total_price)
        FROM Booking b
        WHERE b.user_id = u.user_id
    ) AS total_spent
FROM 
    User u
WHERE 
    (
        SELECT COALESCE(SUM(b.total_price), 0)
        FROM Booking b
        WHERE b.user_id = u.user_id
    ) > (
        SELECT AVG(total_spent_per_user)
        FROM (
            SELECT SUM(total_price) AS total_spent_per_user
            FROM Booking
            GROUP BY user_id
        ) AS user_totals
    )
ORDER BY 
    total_spent DESC;

-- Example 6: Complex correlated subquery - Properties with ratings above location average
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    (
        SELECT AVG(r.rating)
        FROM Review r
        WHERE r.property_id = p.property_id
    ) AS property_avg_rating,
    (
        SELECT AVG(r2.rating)
        FROM Review r2
        INNER JOIN Property p2 ON r2.property_id = p2.property_id
        WHERE p2.location = p.location
    ) AS location_avg_rating
FROM 
    Property p
WHERE 
    (
        SELECT AVG(r.rating)
        FROM Review r
        WHERE r.property_id = p.property_id
    ) > (
        SELECT AVG(r2.rating)
        FROM Review r2
        INNER JOIN Property p2 ON r2.property_id = p2.property_id
        WHERE p2.location = p.location
    )
ORDER BY 
    p.location, property_avg_rating DESC;