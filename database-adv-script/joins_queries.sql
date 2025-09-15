-- =====================================================
-- ALX Airbnb Database Module - Advanced SQL Joins
-- File: joins_queries.sql
-- Purpose: Demonstrate different types of SQL joins
-- =====================================================

-- Task 1: INNER JOIN - Retrieve all bookings and respective users
-- This query returns only bookings that have matching users (excludes orphaned bookings)
SELECT 
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM 
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id
ORDER BY 
    b.booking_id;

-- Task 2: LEFT JOIN - Retrieve all properties and their reviews
-- This query returns all properties, including those without reviews
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    p.host_id,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id
ORDER BY 
    p.property_id, r.created_at;

-- Task 3: FULL OUTER JOIN - Retrieve all users and all bookings
-- This query returns all users and all bookings, including:
-- - Users who have never made a booking
-- - Bookings that are not linked to any user (orphaned bookings)
-- Note: Some databases don't support FULL OUTER JOIN directly, 
-- so we'll use UNION of LEFT and RIGHT JOINs as an alternative

-- Standard FULL OUTER JOIN (for databases that support it)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM 
    User u
FULL OUTER JOIN 
    Booking b ON u.user_id = b.user_id
ORDER BY 
    u.user_id, b.booking_id;

-- Alternative FULL OUTER JOIN using UNION (for MySQL and other databases)
-- Uncomment the following query if your database doesn't support FULL OUTER JOIN
/*
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.booking_id,
    b.property_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM 
    User u
RIGHT JOIN 
    Booking b ON u.user_id = b.user_id
ORDER BY 
    user_id, booking_id;
*/

-- Additional Advanced Join Examples for Learning

-- Example 1: Multiple table joins - Bookings with User and Property details
SELECT 
    b.booking_id,
    u.first_name + ' ' + u.last_name AS guest_name,
    p.name AS property_name,
    p.location,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM 
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id
INNER JOIN 
    Property p ON b.property_id = p.property_id
ORDER BY 
    b.start_date DESC;

-- Example 2: Self-join to find properties in the same location
SELECT 
    p1.property_id AS property1_id,
    p1.name AS property1_name,
    p2.property_id AS property2_id,
    p2.name AS property2_name,
    p1.location
FROM 
    Property p1
INNER JOIN 
    Property p2 ON p1.location = p2.location 
    AND p1.property_id < p2.property_id
ORDER BY 
    p1.location;

-- Example 3: Complex join with filtering - Properties with high-rated reviews
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    AVG(r.rating) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM 
    Property p
INNER JOIN 
    Review r ON p.property_id = r.property_id
WHERE 
    r.rating >= 4
GROUP BY 
    p.property_id, p.name, p.location
HAVING 
    COUNT(r.review_id) >= 3
ORDER BY 
    average_rating DESC;