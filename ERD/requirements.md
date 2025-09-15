# Airbnb Database - Entity-Relationship Diagram

## Project Overview
This document outlines the Entity-Relationship Diagram (ERD) for the Airbnb-like application database. The ERD visualizes the structure, entities, attributes, and relationships within our database system.

## Entities and Attributes

### 1. User
- **user_id** (Primary Key, UUID)
- **first_name** (VARCHAR, NOT NULL)
- **last_name** (VARCHAR, NOT NULL)
- **email** (VARCHAR, UNIQUE, NOT NULL)
- **password_hash** (VARCHAR, NOT NULL)
- **phone_number** (VARCHAR)
- **role** (ENUM: guest, host, admin)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

### 2. Property
- **property_id** (Primary Key, UUID)
- **host_id** (Foreign Key → User.user_id)
- **name** (VARCHAR, NOT NULL)
- **description** (TEXT)
- **location** (VARCHAR, NOT NULL)
- **price_per_night** (DECIMAL, NOT NULL)
- **created_at** (TIMESTAMP)
- **updated_at** (TIMESTAMP)

### 3. Booking
- **booking_id** (Primary Key, UUID)
- **property_id** (Foreign Key → Property.property_id)
- **user_id** (Foreign Key → User.user_id)
- **start_date** (DATE, NOT NULL)
- **end_date** (DATE, NOT NULL)
- **total_price** (DECIMAL, NOT NULL)
- **status** (ENUM: pending, confirmed, canceled)
- **created_at** (TIMESTAMP)

### 4. Payment
- **payment_id** (Primary Key, UUID)
- **booking_id** (Foreign Key → Booking.booking_id)
- **amount** (DECIMAL, NOT NULL)
- **payment_date** (TIMESTAMP)
- **payment_method** (ENUM: credit_card, paypal, stripe)

### 5. Review
- **review_id** (Primary Key, UUID)
- **property_id** (Foreign Key → Property.property_id)
- **user_id** (Foreign Key → User.user_id)
- **rating** (INTEGER, 1-5)
- **comment** (TEXT)
- **created_at** (TIMESTAMP)

### 6. Message
- **message_id** (Primary Key, UUID)
- **sender_id** (Foreign Key → User.user_id)
- **recipient_id** (Foreign Key → User.user_id)
- **message_body** (TEXT, NOT NULL)
- **sent_at** (TIMESTAMP)

## Relationships

### One-to-Many Relationships
1. **User → Property**: One user (host) can own multiple properties
2. **User → Booking**: One user (guest) can make multiple bookings
3. **Property → Booking**: One property can have multiple bookings
4. **Booking → Payment**: One booking can have multiple payments (installments)
5. **Property → Review**: One property can have multiple reviews
6. **User → Review**: One user can write multiple reviews
7. **User → Message (Sender)**: One user can send multiple messages
8. **User → Message (Recipient)**: One user can receive multiple messages

### Key Constraints
- A user cannot book their own property
- Booking dates cannot overlap for the same property
- Reviews can only be written by users who have completed bookings
- Payment amount should match booking total_price

## ERD Visual Representation
```
[User] ──┐
    │    │
    │    ├──→ [Property] ──→ [Booking] ──→ [Payment]
    │    │                      │
    │    └──→ [Review] ←─────────┘
    │
    └──→ [Message] ←──┘
```

## Business Rules
1. Only registered users can make bookings
2. Users can be guests, hosts, or both
3. Properties must have a valid host
4. Bookings require confirmed payment
5. Reviews can only be made after checkout
6. Messages facilitate communication between users

## ERD Tool Used
- **Tool**: Draw.io (https://draw.io)
- **File Format**: .drawio XML export
- **Visual Elements**: Entities, attributes, relationships, cardinalities

## Next Steps
1. Create the visual ERD using Draw.io
2. Export and include the diagram file
3. Proceed to normalization analysis
4. Implement the database schema