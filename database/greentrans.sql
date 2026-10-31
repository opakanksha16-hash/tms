-- =====================================================
-- GreenTrans – Smart Transport & Logistics Management
-- Database Schema
-- =====================================================

CREATE DATABASE IF NOT EXISTS greentrans;
USE greentrans;

-- =====================================================
-- 1. USERS TABLE
-- Stores all users: customers, drivers, managers, admins
-- =====================================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('customer', 'driver', 'manager', 'admin') NOT NULL DEFAULT 'customer',
    profile_image VARCHAR(255) DEFAULT 'default.png',
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    is_active TINYINT(1) DEFAULT 1,
    email_verified TINYINT(1) DEFAULT 0,
    reset_token VARCHAR(255) DEFAULT NULL,
    reset_token_expiry DATETIME DEFAULT NULL,
    last_login DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 2. VEHICLES TABLE
-- Fleet vehicle records
-- =====================================================
CREATE TABLE vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type ENUM('truck', 'mini_truck', 'van', 'trailer', 'tempo') NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    capacity_kg DECIMAL(10,2) DEFAULT 0,
    fuel_type ENUM('diesel', 'petrol', 'cng', 'electric') DEFAULT 'diesel',
    status ENUM('available', 'in_transit', 'maintenance', 'retired') DEFAULT 'available',
    assigned_driver_id INT DEFAULT NULL,
    insurance_expiry DATE,
    fitness_expiry DATE,
    last_service_date DATE,
    mileage_km DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_driver_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 3. SHIPMENTS TABLE
-- Shipment / booking records
-- =====================================================
CREATE TABLE shipments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tracking_id VARCHAR(20) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    driver_id INT DEFAULT NULL,
    vehicle_id INT DEFAULT NULL,
    pickup_address TEXT NOT NULL,
    pickup_city VARCHAR(100) NOT NULL,
    pickup_pincode VARCHAR(10),
    delivery_address TEXT NOT NULL,
    delivery_city VARCHAR(100) NOT NULL,
    delivery_pincode VARCHAR(10),
    package_type ENUM('document', 'parcel', 'fragile', 'heavy', 'bulk') DEFAULT 'parcel',
    weight_kg DECIMAL(10,2) DEFAULT 0,
    dimensions VARCHAR(50),
    status ENUM('pending', 'picked_up', 'in_transit', 'delivered', 'cancelled') DEFAULT 'pending',
    priority ENUM('normal', 'express', 'overnight') DEFAULT 'normal',
    estimated_delivery DATE,
    actual_delivery DATETIME,
    shipping_cost DECIMAL(12,2) DEFAULT 0,
    payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    payment_method ENUM('cash', 'online', 'wallet') DEFAULT 'cash',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 4. SHIPMENT TRACKING TABLE
-- Tracking history / status timeline
-- =====================================================
CREATE TABLE shipment_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    status ENUM('pending', 'picked_up', 'in_transit', 'out_for_delivery', 'delivered', 'cancelled') NOT NULL,
    location VARCHAR(200),
    remarks TEXT,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 5. DELIVERIES TABLE
-- Driver delivery assignments
-- =====================================================
CREATE TABLE deliveries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    driver_id INT NOT NULL,
    vehicle_id INT,
    pickup_time DATETIME,
    delivery_time DATETIME,
    status ENUM('assigned', 'picked_up', 'in_transit', 'delivered', 'failed') DEFAULT 'assigned',
    distance_km DECIMAL(10,2) DEFAULT 0,
    earnings DECIMAL(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 6. INVOICES TABLE
-- Payment / invoice records
-- =====================================================
CREATE TABLE invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(20) NOT NULL UNIQUE,
    shipment_id INT NOT NULL,
    customer_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    payment_method ENUM('cash', 'online', 'wallet') DEFAULT 'cash',
    payment_date DATETIME,
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 7. NOTIFICATIONS TABLE
-- User notification records
-- =====================================================
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('shipment', 'delivery', 'payment', 'system', 'alert') DEFAULT 'system',
    is_read TINYINT(1) DEFAULT 0,
    link VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 8. SUPPORT TICKETS TABLE
-- Customer support requests
-- =====================================================
CREATE TABLE support_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    shipment_id INT DEFAULT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    assigned_to INT DEFAULT NULL,
    response TEXT,
    resolved_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 9. COMPLAINTS TABLE
-- Complaint management
-- =====================================================
CREATE TABLE complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_number VARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    shipment_id INT DEFAULT NULL,
    category ENUM('delivery_delay', 'damaged_package', 'wrong_delivery', 'driver_behavior', 'billing', 'other') NOT NULL,
    description TEXT NOT NULL,
    status ENUM('filed', 'investigating', 'resolved', 'dismissed') DEFAULT 'filed',
    resolution TEXT,
    resolved_by INT DEFAULT NULL,
    resolved_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL,
    FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 10. SETTINGS TABLE
-- System configuration
-- =====================================================
CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_group VARCHAR(50) DEFAULT 'general',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 11. DRIVER AVAILABILITY TABLE
-- Driver availability status
-- =====================================================
CREATE TABLE driver_availability (
    id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL UNIQUE,
    is_available TINYINT(1) DEFAULT 1,
    current_location VARCHAR(200),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- 12. ACTIVITY LOG TABLE
-- User activity history
-- =====================================================
CREATE TABLE activity_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(200) NOT NULL,
    description TEXT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- INSERT DEFAULT DATA
-- =====================================================

-- Default Admin User (password: Admin@123)
INSERT INTO users (full_name, email, phone, password, role, is_active, email_verified) VALUES
('System Admin', 'admin@gmail.com', '9876543210', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1, 1);

-- Default Settings
INSERT INTO settings (setting_key, setting_value, setting_group) VALUES
('site_name', 'GreenTrans', 'general'),
('site_tagline', 'Smart Transport & Logistics Management', 'general'),
('currency', 'INR', 'general'),
('currency_symbol', '₹', 'general'),
('base_rate_per_km', '15', 'pricing'),
('express_multiplier', '1.5', 'pricing'),
('overnight_multiplier', '2.0', 'pricing'),
('tax_percentage', '18', 'pricing'),
('max_weight_kg', '10000', 'shipment'),
('default_eta_days', '5', 'shipment'),
('maintenance_mode', '0', 'system'),
('allow_registration', '1', 'system');

-- Sample Transport Manager
INSERT INTO users (full_name, email, phone, password, role, is_active, email_verified) VALUES
('Rajesh Kumar', 'manager@gmail.com', '9876543211', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'manager', 1, 1);

-- Sample Drivers
INSERT INTO users (full_name, email, phone, password, role, is_active, email_verified) VALUES
('Amit Sharma', 'driver1@gmail.com', '9876543212', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'driver', 1, 1),
('Suresh Yadav', 'driver2@gmail.com', '9876543213', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'driver', 1, 1);

-- Sample Customer
INSERT INTO users (full_name, email, phone, password, role, is_active, email_verified) VALUES
('Priya Patel', 'customer@gmail.com', '9876543214', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer', 1, 1);

-- Driver Availability
INSERT INTO driver_availability (driver_id, is_available, current_location) VALUES
(3, 1, 'Mumbai'),
(4, 1, 'Delhi');

-- Sample Vehicles
INSERT INTO vehicles (vehicle_number, vehicle_type, brand, model, capacity_kg, fuel_type, status, assigned_driver_id) VALUES
('MH12AB1234', 'truck', 'Tata', 'Prima', 16000, 'diesel', 'available', 3),
('DL01CD5678', 'mini_truck', 'Ashok Leyland', 'Dost', 2500, 'diesel', 'available', 4),
('MH04EF9012', 'van', 'Mahindra', 'Supro', 1000, 'diesel', 'available', NULL),
('KA01GH3456', 'trailer', 'Tata', 'Signa', 35000, 'diesel', 'maintenance', NULL),
('GJ05IJ7890', 'tempo', 'Eicher', 'Pro 2049', 5000, 'diesel', 'available', NULL);

-- Sample Shipments
INSERT INTO shipments (tracking_id, customer_id, driver_id, vehicle_id, pickup_address, pickup_city, pickup_pincode, delivery_address, delivery_city, delivery_pincode, package_type, weight_kg, status, priority, estimated_delivery, shipping_cost, payment_status) VALUES
('GT20260001', 5, 3, 1, '123 MG Road, Andheri', 'Mumbai', '400058', '456 Connaught Place', 'Delhi', '110001', 'parcel', 250, 'in_transit', 'express', '2026-05-15', 12500.00, 'paid'),
('GT20260002', 5, 4, 2, '789 Park Street', 'Kolkata', '700016', '101 Brigade Road', 'Bangalore', '560001', 'heavy', 1500, 'picked_up', 'normal', '2026-05-20', 35000.00, 'unpaid'),
('GT20260003', 5, NULL, NULL, '321 Civil Lines', 'Jaipur', '302001', '654 MG Road', 'Pune', '411001', 'document', 2, 'pending', 'overnight', '2026-05-12', 2500.00, 'paid'),
('GT20260004', 5, 3, 1, '555 Anna Nagar', 'Chennai', '600040', '777 Jubilee Hills', 'Hyderabad', '500033', 'fragile', 50, 'delivered', 'express', '2026-05-08', 8750.00, 'paid');

-- Sample Tracking History
INSERT INTO shipment_tracking (shipment_id, status, location, remarks, updated_by) VALUES
(1, 'pending', 'Mumbai', 'Shipment created', 5),
(1, 'picked_up', 'Mumbai', 'Package collected from sender', 3),
(1, 'in_transit', 'Nashik', 'In transit via highway', 3),
(4, 'pending', 'Chennai', 'Shipment created', 5),
(4, 'picked_up', 'Chennai', 'Package collected', 3),
(4, 'in_transit', 'Kurnool', 'In transit', 3),
(4, 'delivered', 'Hyderabad', 'Delivered successfully', 3);

-- Sample Deliveries
INSERT INTO deliveries (shipment_id, driver_id, vehicle_id, status, distance_km, earnings) VALUES
(1, 3, 1, 'in_transit', 1400, 3500),
(2, 4, 2, 'picked_up', 1850, 0),
(4, 3, 1, 'delivered', 630, 2100);

-- Sample Invoices
INSERT INTO invoices (invoice_number, shipment_id, customer_id, amount, tax_amount, total_amount, payment_status, payment_date) VALUES
('INV20260001', 1, 5, 10593.22, 1906.78, 12500.00, 'paid', '2026-05-09 10:00:00'),
('INV20260003', 3, 5, 2118.64, 381.36, 2500.00, 'paid', '2026-05-09 11:00:00'),
('INV20260004', 4, 5, 7415.25, 1334.75, 8750.00, 'paid', '2026-05-07 14:00:00');

-- Sample Notifications
INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(5, 'Shipment In Transit', 'Your shipment GT20260001 is now in transit.', 'shipment', 0),
(5, 'Payment Received', 'Payment of ₹12,500 received for shipment GT20260001.', 'payment', 1),
(3, 'New Delivery Assigned', 'You have a new delivery assignment for GT20260001.', 'delivery', 0),
(5, 'Shipment Delivered', 'Your shipment GT20260004 has been delivered successfully.', 'shipment', 1),
(1, 'New Registration', 'A new customer has registered on GreenTrans.', 'system', 0);
