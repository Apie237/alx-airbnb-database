# Database Schema - DDL Scripts

## Overview
This directory contains the Data Definition Language (DDL) scripts for creating the Airbnb database schema. The schema is designed to support a full-featured property rental platform with users, properties, bookings, payments, reviews, and messaging functionality.

## Files
- `schema.sql` - Complete database schema creation script

## Database Design Features

### 🏗️ Core Architecture
- **Normalized Design**: Follows 3NF principles
- **UUID Primary Keys**: Globally unique identifiers
- **Referential Integrity**: Proper foreign key constraints
- **Data Validation**: Check constraints for business rules
- **Performance Optimization**: Strategic indexing

### 📊 Tables Created

#### 1. User Table
- Stores user account information
- Supports multiple roles: guest, host, admin
- Email uniqueness enforced
- Password hash storage (never plain text)

#### 2. Property Table
- Property listings with host relationships
- Price validation and location data
- Automatic timestamp tracking

#### 3. Booking Table
- Booking management with date validation
- Status tracking (pending, confirmed, canceled)
- Price calculation and storage

#### 4. Payment Table
- Payment processing records
- Multiple payment method support
- Booking relationship maintained

#### 5. Review Table
- User reviews for properties
- Rating system (1-5 stars)
- Prevents duplicate reviews per user/property

#### 6. Message Table
- User-to-user communication
- Prevents self-messaging
- Message content validation

## 🚀 Performance Features

### Indexes Created
- **Single Column Indexes**: For frequently queried columns
- **Composite Indexes**: For complex query optimization
- **Unique Indexes**: For data integrity

### Key Optimization Areas
- User lookup by email
- Property search by location and price
- Booking queries by date ranges
- Review aggregation by property

## 🔒 Security & Constraints

### Data Validation
- Email format validation
- Phone number format checking
- Date range validation for bookings
- Price positivity constraints
- Rating range enforcement (1-5)

### Business Logic Constraints
- Users cannot book their own properties
- Booking dates must be logical (start < end)
- Future booking validation
- Unique user-property review combinations

## 🛠️ Additional Features

### Views
- `v_property_details`: Property information with host details
- `v_booking_details`: Complete booking information with names

### Stored Procedures
- `CheckBookingAvailability`: Validates booking date conflicts

### Triggers
- Automatic timestamp updates on record modifications

## 📋 Installation Instructions

### Prerequisites
- MySQL 8.0+ or PostgreSQL 12+
- Database administrator privileges
- UTF-8 character set support

### MySQL Setup
```bash
# Login to MySQL
mysql -u root -p

# Create database
CREATE DATABASE airbnb_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Use database
USE airbnb_db;

# Run schema script
source /path/to/schema.sql;
```

### PostgreSQL Setup
```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE airbnb_db WITH ENCODING 'UTF8';

# Connect to database
\c airbnb_db;

# Run schema script
\i /path/to/schema.sql;
```

## 🔧 Configuration Notes

### UUID Support
- **MySQL**: Uses UUID() function
- **PostgreSQL**: Requires uuid-ossp extension
- Adjust UUID generation based on your database system

### Enum Types
- Database-specific enum implementations
- Consider using lookup tables for maximum portability

### Timestamp Handling
- Uses database-specific timestamp functions
- Automatic timezone handling recommended

## 📈 Performance Considerations

### Query Optimization
- Indexes cover common query patterns
- Composite indexes for multi-column searches
- Consider partitioning for large datasets

### Scaling Recommendations
- Monitor index usage and performance
- Consider read replicas for heavy read workloads
- Implement caching layers for frequent queries

## 🧪 Testing the Schema

### Validation Steps
```sql
-- Check all tables created
SHOW TABLES;

-- Verify indexes
SHOW INDEX FROM User;
SHOW INDEX FROM Property;
SHOW INDEX FROM Booking;

-- Test constraints
INSERT INTO User (first_name, last_name, email, password_hash) 
VALUES ('Test', 'User', 'invalid-email', 'hash'); -- Should fail

-- Test foreign key relationships
INSERT INTO Property (host_id, name, location, price_per_night) 
VALUES ('invalid-uuid', 'Test Property', 'Test Location', 100.00); -- Should fail
```

## 🔄 Migration Support

### Future Schema Changes
- Use ALTER TABLE statements for modifications
- Backup data before structural changes
- Consider versioning for schema migrations

### Version Control
- Tag schema versions in git
- Document breaking changes
- Provide rollback procedures

## 📚 Documentation

### Related Files
- `../ERD/requirements.md` - Entity relationship documentation
- `../normalization.md` - Database normalization analysis
- `../database-script-0x02/seed.sql` - Sample data insertion

### Business Rules Implemented
- User authentication and authorization
- Property ownership and management
- Booking lifecycle management
- Payment tracking and validation
- Review system integrity
- Inter-user communication

## ⚠️ Important Notes

### Security Considerations
- Password hashes only (never plain text)
- Input validation at application layer
- SQL injection prevention through parameterized queries
- Regular security audits recommended

### Maintenance Tasks
- Regular index optimization
- Database statistics updates
- Performance monitoring
- Backup and recovery procedures

## 🤝 Support

For questions or issues with the database schema:
1. Check the ERD documentation for design rationale
2. Review normalization analysis for structural decisions
3. Consult database-specific documentation for platform issues
4. Consider performance implications for any modifications

---
**Created by**: ALX Student  
**Version**: 1.0  
**Last Updated**: 2024  
**Database Systems**: MySQL 8.0+, PostgreSQL 12+