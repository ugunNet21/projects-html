-- Set database character set and collation
-- Adjust if needed for specific language support beyond standard Indonesian
ALTER DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Table: `locations`
-- Represents different branches or outlets if the business has multiple locations.
-- ---------------------------------------------------------------------
CREATE TABLE `locations` (
    `location_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the location',
    `name` VARCHAR(100) NOT NULL COMMENT 'Name of the location/branch',
    `address` TEXT COMMENT 'Full address of the location',
    `phone_number` VARCHAR(50) COMMENT 'Contact phone number for the location',
    `email` VARCHAR(100) COMMENT 'Contact email for the location',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Is the location currently active?',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated'
) COMMENT='Stores information about laundry locations/branches';

-- ---------------------------------------------------------------------
-- Table: `users`
-- Represents employees or staff with access to the system.
-- Users are linked to a location, but can be NULL for admin/HQ users.
-- ---------------------------------------------------------------------
CREATE TABLE `users` (
    `user_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the user',
    `username` VARCHAR(50) UNIQUE NOT NULL COMMENT 'Login username (should be unique)',
    `password_hash` VARCHAR(255) NOT NULL COMMENT 'Hashed password for security',
    `name` VARCHAR(100) NOT NULL COMMENT 'Full name of the user',
    `role` ENUM('admin', 'manager', 'staff', 'courier') NOT NULL COMMENT 'User role defining permissions',
    `phone_number` VARCHAR(50) COMMENT 'User contact phone number',
    `email` VARCHAR(100) COMMENT 'User contact email',
    `location_id` VARCHAR(36) NULL COMMENT 'Foreign Key to locations table (can be NULL for HQ/Admin)',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Is the user account active?',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (`location_id`) REFERENCES `locations`(`location_id`) ON DELETE SET NULL ON UPDATE CASCADE -- If a location is deleted, users linked to it will have location_id set to NULL
) COMMENT='Stores information about system users/employees';

-- ---------------------------------------------------------------------
-- Table: `customers`
-- Stores information about customers.
-- ---------------------------------------------------------------------
CREATE TABLE `customers` (
    `customer_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the customer',
    `name` VARCHAR(100) NOT NULL COMMENT 'Customer''s full name',
    `phone_number` VARCHAR(50) UNIQUE NULL COMMENT 'Customer''s phone number (optional but recommended for communication, UNIQUE)',
    `email` VARCHAR(100) UNIQUE NULL COMMENT 'Customer''s email address (optional, UNIQUE)',
    `address` TEXT COMMENT 'Customer''s address',
    `loyalty_points` INT NOT NULL DEFAULT 0 COMMENT 'Accumulated loyalty points',
    `notes` TEXT COMMENT 'Internal notes about the customer',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated'
) COMMENT='Stores information about customers';

-- Add index for frequently searched fields
CREATE INDEX idx_customers_phone_email ON `customers`(`phone_number`, `email`);

-- ---------------------------------------------------------------------
-- Table: `services`
-- Defines the types of laundry services offered (e.g., Cuci Kiloan, Dry Clean Kemeja).
-- ---------------------------------------------------------------------
CREATE TABLE `services` (
    `service_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the service',
    `name` VARCHAR(100) NOT NULL COMMENT 'Name of the service (e.g., Cuci Kiloan, Dry Clean, Setrika Saja)',
    `unit` ENUM('kg', 'piece', 'set', 'pair') NOT NULL COMMENT 'Unit of measurement for this service',
    `base_price` DECIMAL(10, 2) NOT NULL COMMENT 'Base price per unit',
    `description` TEXT COMMENT 'Description of the service',
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Is this service currently offered?',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated'
) COMMENT='Defines available laundry services';

-- ---------------------------------------------------------------------
-- Table: `items`
-- Generic list of item types (e.g., T-Shirt, Jeans, Bed Sheet).
-- Used for item-based services and detailed tracking.
-- ---------------------------------------------------------------------
CREATE TABLE `items` (
    `item_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the item type',
    `name` VARCHAR(100) NOT NULL COMMENT 'Name of the item type (e.g., Kemeja, Celana Jeans)',
    `category` VARCHAR(100) COMMENT 'Category of the item (e.g., Pakaian Atas, Selimut)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated'
) COMMENT='Defines generic item types (e.g., Kemeja, Celana)';

-- ---------------------------------------------------------------------
-- Table: `service_item_prices`
-- Stores specific prices for 'piece' based services linked to specific item types.
-- ---------------------------------------------------------------------
CREATE TABLE `service_item_prices` (
    `service_item_price_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the service-item price entry',
    `service_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the services table',
    `item_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the items table',
    `price` DECIMAL(10, 2) NOT NULL COMMENT 'Price for this specific service-item combination',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    UNIQUE KEY `uk_service_item` (`service_id`, `item_id`), -- Ensure only one price per service-item combination
    FOREIGN KEY (`service_id`) REFERENCES `services`(`service_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`item_id`) REFERENCES `items`(`item_id`) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT='Stores prices for piece-based services linked to specific item types';

-- ---------------------------------------------------------------------
-- Table: `orders`
-- Main table for each laundry order transaction.
-- ---------------------------------------------------------------------
CREATE TABLE `orders` (
    `order_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the order',
    `order_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'Human-readable unique order number (e.g., LNDRY-YYYYMMDD-XXXX)',
    `customer_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the customers table',
    `received_at_location_id` VARCHAR(36) COMMENT 'Location where the order was received',
    `processed_at_location_id` VARCHAR(36) COMMENT 'Location where the order is being processed',
    `received_by_user_id` VARCHAR(36) COMMENT 'User who received the order',
    `order_date` DATETIME NOT NULL COMMENT 'Date and time when the order was created',
    `pickup_date` DATETIME NULL COMMENT 'Scheduled date and time for pickup (if applicable)',
    `due_date` DATETIME NULL COMMENT 'Promised completion date and time',
    `completed_date` DATETIME NULL COMMENT 'Actual completion date and time',
    `delivered_date` DATETIME NULL COMMENT 'Date and time when the order was delivered/picked up by customer',
    `status` ENUM('Draft', 'Pending', 'Processing', 'Ready for Pickup/Delivery', 'Completed', 'Cancelled', 'Problem') NOT NULL DEFAULT 'Draft' COMMENT 'Current status of the order',
    `total_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Calculated total amount before discount',
    `discount_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Total discount applied',
    `final_amount` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Final amount after discount',
    `payment_status` ENUM('Pending', 'Partial', 'Paid', 'Refunded') NOT NULL DEFAULT 'Pending' COMMENT 'Payment status of the order',
    `customer_notes` TEXT COMMENT 'Notes from the customer about the order',
    `internal_notes` TEXT COMMENT 'Internal notes about the order',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`received_at_location_id`) REFERENCES `locations`(`location_id`) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (`processed_at_location_id`) REFERENCES `locations`(`location_id`) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (`received_by_user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT='Stores information about laundry orders';

-- Add indexes for frequently searched fields
CREATE INDEX idx_orders_customer_status ON `orders`(`customer_id`, `status`);
CREATE INDEX idx_orders_date ON `orders`(`order_date`);
CREATE INDEX idx_orders_location_status ON `orders`(`processed_at_location_id`, `status`);


-- ---------------------------------------------------------------------
-- Table: `order_items`
-- Details of each item or group of items within an order.
-- This is where item counting or weight is recorded per service.
-- ---------------------------------------------------------------------
CREATE TABLE `order_items` (
    `order_item_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the order item entry',
    `order_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the orders table',
    `service_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the services table (what service is applied)',
    `item_id` VARCHAR(36) NULL COMMENT 'Foreign Key to the items table (what item type, NULL for kiloan services)',
    `quantity` DECIMAL(10, 2) NOT NULL COMMENT 'Quantity (in pieces or kg) based on service unit',
    `unit_price` DECIMAL(10, 2) NOT NULL COMMENT 'Price per unit at the time of order creation',
    `subtotal` DECIMAL(10, 2) NOT NULL COMMENT 'Subtotal for this item (quantity * unit_price)',
    `notes` TEXT COMMENT 'Notes specific to this item (e.g., "noda di saku")',
    `status` ENUM('Received', 'Inspected', 'Washing', 'Drying', 'Finishing', 'Ready', 'Delivered/Picked Up', 'Problem', 'Cancelled') NOT NULL DEFAULT 'Received' COMMENT 'Status of this specific item within the order',
    `processed_by_user_id` VARCHAR(36) NULL COMMENT 'User who last processed this item',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE ON UPDATE CASCADE, -- If an order is deleted, its items are deleted
    FOREIGN KEY (`service_id`) REFERENCES `services`(`service_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`item_id`) REFERENCES `items`(`item_id`) ON DELETE SET NULL ON UPDATE CASCADE, -- If an item type is deleted, the link is set to NULL
    FOREIGN KEY (`processed_by_user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT='Details of items within an order (including quantity/weight per service)';

-- Add indexes for linking to parent order and status
CREATE INDEX idx_order_items_order ON `order_items`(`order_id`);
CREATE INDEX idx_order_items_status ON `order_items`(`status`);


-- ---------------------------------------------------------------------
-- Table: `order_item_inspections`
-- Detailed notes on inspection for specific items within an order.
-- Allows multiple inspection notes per order item.
-- ---------------------------------------------------------------------
CREATE TABLE `order_item_inspections` (
    `inspection_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the inspection record',
    `order_item_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the order_items table',
    `inspected_by_user_id` VARCHAR(36) NULL COMMENT 'User who performed the inspection',
    `inspection_date` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time of the inspection',
    `inspection_notes` TEXT NOT NULL COMMENT 'Detailed notes (stains, damage, etc.)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (`order_item_id`) REFERENCES `order_items`(`order_item_id`) ON DELETE CASCADE ON UPDATE CASCADE, -- If an order item is deleted, its inspections are deleted
    FOREIGN KEY (`inspected_by_user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT='Records detailed inspection notes for specific order items';

-- Add index for linking to order item
CREATE INDEX idx_item_inspections_order_item ON `order_item_inspections`(`order_item_id`);


-- ---------------------------------------------------------------------
-- Table: `payments`
-- Records payment transactions for orders.
-- Allows for partial payments.
-- ---------------------------------------------------------------------
CREATE TABLE `payments` (
    `payment_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the payment transaction',
    `order_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the orders table',
    `payment_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time of the payment',
    `amount` DECIMAL(10, 2) NOT NULL COMMENT 'Amount paid in this transaction',
    `method` ENUM('Cash', 'Transfer', 'Card', 'E-wallet', 'Other') NOT NULL COMMENT 'Payment method used',
    `transaction_id` VARCHAR(100) NULL COMMENT 'External transaction ID (e.g., bank transfer ref, payment gateway ID)',
    `received_by_user_id` VARCHAR(36) NULL COMMENT 'User who received the payment',
    `notes` TEXT COMMENT 'Notes about the payment',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE ON UPDATE CASCADE, -- If an order is deleted, its payments are deleted
    FOREIGN KEY (`received_by_user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT='Records payment transactions for orders';

-- Add index for linking to order
CREATE INDEX idx_payments_order ON `payments`(`order_id`);


-- ---------------------------------------------------------------------
-- Table: `order_status_history`
-- Tracks changes in the status of an order.
-- Provides an audit trail.
-- ---------------------------------------------------------------------
CREATE TABLE `order_status_history` (
    `history_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the status history record',
    `order_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the orders table',
    `old_status` VARCHAR(50) COMMENT 'Previous status of the order',
    `new_status` VARCHAR(50) NOT NULL COMMENT 'New status of the order',
    `change_timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the status changed',
    `changed_by_user_id` VARCHAR(36) NULL COMMENT 'User who changed the status (NULL for system changes)',
    `notes` TEXT COMMENT 'Optional notes about the status change',
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE ON UPDATE CASCADE, -- If an order is deleted, its status history is deleted
    FOREIGN KEY (`changed_by_user_id`) REFERENCES `users`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT='Tracks historical status changes for orders';

-- Add index for linking to order and timestamp
CREATE INDEX idx_status_history_order_timestamp ON `order_status_history`(`order_id`, `change_timestamp`);


-- ---------------------------------------------------------------------
-- Table: `notifications`
-- Stores notifications to be sent to customers (e.g., order ready).
-- Supports multiple communication channels.
-- ---------------------------------------------------------------------
CREATE TABLE `notifications` (
    `notification_id` VARCHAR(36) PRIMARY KEY COMMENT 'UUID for the notification',
    `customer_id` VARCHAR(36) NOT NULL COMMENT 'Foreign Key to the customers table',
    `order_id` VARCHAR(36) NULL COMMENT 'Foreign Key to the orders table (optional, if notification is order-specific)',
    `type` ENUM('OrderStatusUpdate', 'ReadyForPickup', 'PaymentReminder', 'Promo', 'Other') NOT NULL COMMENT 'Type of notification',
    `message` TEXT NOT NULL COMMENT 'The content of the notification message',
    `sent_via` ENUM('SMS', 'Email', 'AppPush', 'Other') COMMENT 'Channel used to send the notification',
    `status` ENUM('Pending', 'Sent', 'Failed', 'Read', 'Cancelled') NOT NULL DEFAULT 'Pending' COMMENT 'Status of the notification',
    `scheduled_send_time` DATETIME NULL COMMENT 'If the notification is scheduled for future sending',
    `sent_at` DATETIME NULL COMMENT 'Timestamp when the notification was actually sent',
    `read_at` DATETIME NULL COMMENT 'Timestamp when the customer read the notification (if applicable)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE, -- If a customer is deleted, their notifications are deleted
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE ON UPDATE CASCADE -- If an order is deleted, related notifications are deleted
) COMMENT='Stores customer notifications';

-- Add index for customer and status
CREATE INDEX idx_notifications_customer_status ON `notifications`(`customer_id`, `status`);