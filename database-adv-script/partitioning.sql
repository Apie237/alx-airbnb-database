-- Task 5: Partitioning Large Tables
-- ALX Airbnb Database Module

-- Step 1: Create the partitioned Booking table
-- This assumes we're using PostgreSQL. Adjust syntax for other databases.

-- First, let's create the partitioned table structure
CREATE TABLE Booking_Partitioned (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (start_date);

-- Step 2: Create individual partitions for different date ranges

-- Partition for bookings in 2023
CREATE TABLE Booking_2023 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- Partition for Q1 2024
CREATE TABLE Booking_2024_Q1 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- Partition for Q2 2024
CREATE TABLE Booking_2024_Q2 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Partition for Q3 2024
CREATE TABLE Booking_2024_Q3 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

-- Partition for Q4 2024
CREATE TABLE Booking_2024_Q4 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- Partition for Q1 2025
CREATE TABLE Booking_2025_Q1 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

-- Partition for Q2 2025
CREATE TABLE Booking_2025_Q2 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

-- Partition for Q3 2025
CREATE TABLE Booking_2025_Q3 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

-- Partition for Q4 2025
CREATE TABLE Booking_2025_Q4 PARTITION OF Booking_Partitioned
FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- Default partition for any dates outside the specified ranges
CREATE TABLE Booking_Default PARTITION OF Booking_Partitioned DEFAULT;

-- Step 3: Create indexes on partitioned table
-- These indexes will be created on each partition automatically

CREATE INDEX idx_booking_part_user_id ON Booking_Partitioned(user_id);
CREATE INDEX idx_booking_part_property_id ON Booking_Partitioned(property_id);
CREATE INDEX idx_booking_part_status ON Booking_Partitioned(status);
CREATE INDEX idx_booking_part_dates ON Booking_Partitioned(start_date, end_date);
CREATE INDEX idx_booking_part_created_at ON Booking_Partitioned(created_at);

-- Step 4: Create foreign key constraints
ALTER TABLE Booking_Partitioned 
ADD CONSTRAINT fk_booking_part_user 
FOREIGN KEY (user_id) REFERENCES User(user_id);

ALTER TABLE Booking_Partitioned 
ADD CONSTRAINT fk_booking_part_property 
FOREIGN KEY (property_id) REFERENCES Property(property_id);

-- Step 5: Migration script to copy data from original table (if exists)
-- This assumes you have an existing Booking table

-- Insert data from original table to partitioned table
INSERT INTO Booking_Partitioned (
    booking_id, property_id, user_id, start_date, end_date, 
    total_price, status, created_at, updated_at
)
SELECT 
    booking_id, property_id, user_id, start_date, end_date, 
    total_price, status, created_at, updated_at
FROM Booking;

-- Step 6: Performance testing queries for partitioned table

-- Test 1: Query specific date range (should use partition pruning)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    p.name AS property_name
FROM Booking_Partitioned b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-01-01' 
  AND b.start_date < '2024-04-01'
  AND b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- Test 2: Query across multiple partitions
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT 
    DATE_TRUNC('month', start_date) AS booking_month,
    COUNT(*) AS total_bookings,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS avg_booking_value
FROM Booking_Partitioned
WHERE start_date >= '2024-01-01' 
  AND start_date < '2025-01-01'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY booking_month;

-- Test 3: Query single partition vs multiple partitions
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT COUNT(*) 
FROM Booking_Partitioned 
WHERE start_date >= '2024-01-01' AND start_date < '2024-01-31';

-- Test 4: Compare performance with original table
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT COUNT(*) 
FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date < '2024-01-31';

-- Step 7: Maintenance queries for partitioned table

-- Query to check partition sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE tablename LIKE 'booking_%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Query to check partition pruning
SELECT 
    query,
    calls,
    total_time,
    mean_time
FROM pg_stat_statements 
WHERE query LIKE '%Booking_Partitioned%'
ORDER BY total_time DESC;

-- Step 8: Automated partition management (PostgreSQL specific)

-- Function to create future partitions automatically
CREATE OR REPLACE FUNCTION create_quarterly_partitions(start_date DATE, num_quarters INTEGER)
RETURNS VOID AS $
DECLARE
    partition_start DATE;
    partition_end DATE;
    partition_name TEXT;
    quarter_start DATE;
    i INTEGER;
BEGIN
    quarter_start := DATE_TRUNC('quarter', start_date);
    
    FOR i IN 0..num_quarters-1 LOOP
        partition_start := quarter_start + (i * INTERVAL '3 months');
        partition_end := partition_start + INTERVAL '3 months';
        partition_name := 'booking_' || TO_CHAR(partition_start, 'YYYY_Q') || 'q' || TO_CHAR(partition_start, 'Q');
        
        EXECUTE FORMAT('CREATE TABLE %I PARTITION OF booking_partitioned FOR VALUES FROM (%L) TO (%L)',
                      partition_name, partition_start, partition_end);
    END LOOP;
END;
$ LANGUAGE plpgsql;

-- Create partitions for the next 8 quarters
SELECT create_quarterly_partitions('2026-01-01', 8);

-- Step 9: Alternative partitioning strategies

-- Hash partitioning by user_id (for load distribution)
CREATE TABLE Booking_Hash_Partitioned (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY HASH (user_id);

-- Create 4 hash partitions
CREATE TABLE Booking_Hash_0 PARTITION OF Booking_Hash_Partitioned FOR VALUES WITH (modulus 4, remainder 0);
CREATE TABLE Booking_Hash_1 PARTITION OF Booking_Hash_Partitioned FOR VALUES WITH (modulus 4, remainder 1);
CREATE TABLE Booking_Hash_2 PARTITION OF Booking_Hash_Partitioned FOR VALUES WITH (modulus 4, remainder 2);
CREATE TABLE Booking_Hash_3 PARTITION OF Booking_Hash_Partitioned FOR VALUES WITH (modulus 4, remainder 3);

-- List partitioning by status
CREATE TABLE Booking_List_Partitioned (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY LIST (status);

-- Create partitions for each status
CREATE TABLE Booking_Pending PARTITION OF Booking_List_Partitioned FOR VALUES IN ('pending');
CREATE TABLE Booking_Confirmed PARTITION OF Booking_List_Partitioned FOR VALUES IN ('confirmed');
CREATE TABLE Booking_Canceled PARTITION OF Booking_List_Partitioned FOR VALUES IN ('canceled');

-- Step 10: Monitoring and maintenance queries

-- Check constraint exclusion (partition pruning)
SET constraint_exclusion = partition;

-- Monitor partition-wise joins
SET enable_partitionwise_join = on;
SET enable_partitionwise_aggregate = on;

-- Query to analyze partition usage
SELECT 
    schemaname,
    tablename,
    n_tup_ins AS inserts,
    n_tup_upd AS updates,
    n_tup_del AS deletes,
    n_live_tup AS live_tuples,
    n_dead_tup AS dead_tuples,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables 
WHERE tablename LIKE 'booking_%'
ORDER BY tablename;

-- Cleanup old partitions (example for data retention)
-- DROP TABLE IF EXISTS Booking_2023; -- Only if data retention policy allows