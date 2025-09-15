-- Task 1: Practice Subqueries
-- ALX Airbnb Database Module

-- 1. Find all properties where the average rating is greater than 4.0 using a subquery
SELECT 
    p.property_id,
    p.name,
    p.description,
    p.location,
    p.pricepernight,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name
FROM Property p
JOIN User h ON p.host_id = h.user_id
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- Alternative subquery approach using EXISTS
SELECT 
    p.property_id,
    p.name,
    p.description,
    p.location,
    p.pricepernight
FROM Property p
WHERE EXISTS (
    SELECT 1
    FROM Review r
    WHERE r.property_id = p.property_id
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- 2. Correlated subquery to find users who have made more than 3 bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    (
        SELECT COUNT(*)
        FROM Booking b
        WHERE b.user_id = u.user_id
    ) AS total_bookings
FROM User u
WHERE (
    SELECT COUNT(*)
    FROM Booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY total_bookings DESC;

-- Additional subquery: Find properties with no reviews
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight
FROM Property p
WHERE p.property_id NOT IN (
    SELECT DISTINCT r.property_id
    FROM Review r
    WHERE r.property_id IS NOT NULL
)
ORDER BY p.name;

-- Subquery to find users who have never made a booking
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.created_at
FROM User u
WHERE u.user_id NOT IN (
    SELECT DISTINCT b.user_id
    FROM Booking b
    WHERE b.user_id IS NOT NULL
)
AND u.role = 'guest'
ORDER BY u.created_at DESC;