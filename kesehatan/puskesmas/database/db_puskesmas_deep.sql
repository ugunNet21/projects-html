-- 1. Users & Authentication
CREATE TABLE `users` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `email_verified_at` TIMESTAMP NULL,
    `password` VARCHAR(255) NOT NULL,
    `remember_token` VARCHAR(100) NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    `deleted_at` TIMESTAMP NULL,
    UNIQUE (`email`)
);

CREATE TABLE `password_reset_tokens` (
    `email` VARCHAR(255) NOT NULL PRIMARY KEY,
    `token` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP NULL
);

CREATE TABLE `sessions` (
    `id` VARCHAR(255) NOT NULL PRIMARY KEY,
    `user_id` CHAR(36) NULL,
    `ip_address` VARCHAR(45) NULL,
    `user_agent` TEXT NULL,
    `payload` LONGTEXT NOT NULL,
    `last_activity` INT NOT NULL,
    INDEX `idx_sessions_user_id` (`user_id`),
    INDEX `idx_sessions_last_activity` (`last_activity`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
);

-- 2. Spatie Permission Tables
CREATE TABLE `roles` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `guard_name` VARCHAR(255) NOT NULL DEFAULT 'web',
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    UNIQUE (`name`)
);

CREATE TABLE `permissions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `guard_name` VARCHAR(255) NOT NULL DEFAULT 'web',
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    UNIQUE (`name`)
);

CREATE TABLE `model_has_permissions` (
    `permission_id` CHAR(36) NOT NULL,
    `model_type` VARCHAR(255) NOT NULL,
    `model_id` CHAR(36) NOT NULL,
    PRIMARY KEY (`permission_id`, `model_id`, `model_type`),
    FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
);

CREATE TABLE `model_has_roles` (
    `role_id` CHAR(36) NOT NULL,
    `model_type` VARCHAR(255) NOT NULL,
    `model_id` CHAR(36) NOT NULL,
    PRIMARY KEY (`role_id`, `model_id`, `model_type`),
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
);

CREATE TABLE `role_has_permissions` (
    `permission_id` CHAR(36) NOT NULL,
    `role_id` CHAR(36) NOT NULL,
    PRIMARY KEY (`permission_id`, `role_id`),
    FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
);

-- 3. Staff & Personnel
CREATE TABLE `staff` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `user_id` CHAR(36) NOT NULL,
    `nip` VARCHAR(255) NULL,
    `position` VARCHAR(255) NOT NULL,
    `specialization` VARCHAR(255) NULL,
    `phone` VARCHAR(255) NULL,
    `join_date` DATE NOT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    `deleted_at` TIMESTAMP NULL,
    UNIQUE (`nip`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
);

CREATE TABLE `staff_schedules` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `staff_id` CHAR(36) NOT NULL,
    `day` ENUM('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday') NOT NULL,
    `start_time` TIME NOT NULL,
    `end_time` TIME NOT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
);

-- 4. Patients
CREATE TABLE `patients` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `nik` VARCHAR(255) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `birth_place` VARCHAR(255) NOT NULL,
    `birth_date` DATE NOT NULL,
    `gender` ENUM('male', 'female') NOT NULL,
    `address` TEXT NOT NULL,
    `phone` VARCHAR(255) NULL,
    `bpjs_number` VARCHAR(255) NULL,
    `blood_type` VARCHAR(255) NULL,
    `allergy` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    `deleted_at` TIMESTAMP NULL,
    UNIQUE (`nik`)
);

-- 5. Registration & Queue
CREATE TABLE `services` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `code` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    UNIQUE (`code`)
);

CREATE TABLE `registrations` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `patient_id` CHAR(36) NOT NULL,
    `service_id` CHAR(36) NOT NULL,
    `registration_number` VARCHAR(255) NOT NULL,
    `registration_date` DATE NOT NULL,
    `status` ENUM('waiting', 'in_progress', 'completed', 'canceled') NOT NULL DEFAULT 'waiting',
    `complaint` TEXT NOT NULL,
    `queue_number` INT NOT NULL,
    `is_bpjs` TINYINT(1) NOT NULL DEFAULT 0,
    `bpjs_number` VARCHAR(255) NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    UNIQUE (`registration_number`),
    FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
);

CREATE TABLE `vital_signs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `registration_id` CHAR(36) NOT NULL,
    `height` DECIMAL(10, 2) NULL,
    `weight` DECIMAL(10, 2) NULL,
    `blood_pressure_systolic` INT NULL,
    `blood_pressure_diastolic` INT NULL,
    `temperature` DECIMAL(10, 2) NULL,
    `pulse` INT NULL,
    `respiration` INT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`) ON DELETE CASCADE
);

-- 6. Medical Records
CREATE TABLE `medical_records` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `registration_id` CHAR(36) NOT NULL,
    `staff_id` CHAR(36) NOT NULL,
    `diagnosis` TEXT NOT NULL,
    `treatment` TEXT NOT NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
);

CREATE TABLE `prescriptions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `medical_record_id` CHAR(36) NOT NULL,
    `instructions` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`medical_record_id`) REFERENCES `medical_records` (`id`) ON DELETE CASCADE
);

CREATE TABLE `medicines` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `code` VARCHAR(255) NOT NULL,
    `category` VARCHAR(255) NOT NULL,
    `unit` VARCHAR(255) NOT NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    `stock` INT NOT NULL,
    `min_stock` INT NOT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    UNIQUE (`code`)
);

CREATE TABLE `prescription_items` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `prescription_id` CHAR(36) NOT NULL,
    `medicine_id` CHAR(36) NOT NULL,
    `quantity` INT NOT NULL,
    `dosage` TEXT NOT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`medicine_id`) REFERENCES `medicines` (`id`) ON DELETE CASCADE
);

-- 7. Laboratory
CREATE TABLE `lab_tests` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL
);

CREATE TABLE `lab_orders` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `medical_record_id` CHAR(36) NOT NULL,
    `notes` TEXT NULL,
    `status` ENUM('pending', 'in_progress', 'completed') NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`medical_record_id`) REFERENCES `medical_records` (`id`) ON DELETE CASCADE
);

CREATE TABLE `lab_order_items` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `lab_order_id` CHAR(36) NOT NULL,
    `lab_test_id` CHAR(36) NOT NULL,
    `result` TEXT NULL,
    `normal_range` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`lab_order_id`) REFERENCES `lab_orders` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`lab_test_id`) REFERENCES `lab_tests` (`id`) ON DELETE CASCADE
);

-- 8. Maternal & Child Health
CREATE TABLE `pregnant_women` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `patient_id` CHAR(36) NOT NULL,
    `gravida` INT NOT NULL,
    `para` INT NOT NULL,
    `abortus` INT NOT NULL,
    `hpht` DATE NOT NULL,
    `estimated_due_date` DATE NOT NULL,
    `height` INT NOT NULL,
    `lila` INT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
);

CREATE TABLE `prenatal_visits` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `pregnant_woman_id` CHAR(36) NOT NULL,
    `visit_date` DATE NOT NULL,
    `gestational_age` INT NOT NULL,
    `weight` INT NOT NULL,
    `blood_pressure_systolic` INT NOT NULL,
    `blood_pressure_diastolic` INT NOT NULL,
    `fundal_height` INT NOT NULL,
    `fetal_position` VARCHAR(255) NULL,
    `fetal_heart_rate` INT NULL,
    `complaint` TEXT NULL,
    `treatment` TEXT NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`pregnant_woman_id`) REFERENCES `pregnant_women` (`id`) ON DELETE CASCADE
);

CREATE TABLE `immunizations` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL
);

CREATE TABLE `immunization_schedules` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `patient_id` CHAR(36) NOT NULL,
    `immunization_id` CHAR(36) NOT NULL,
    `schedule_date` DATE NOT NULL,
    `given_date` DATE NULL,
    `staff_id` CHAR(36) NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`immunization_id`) REFERENCES `immunizations` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
);

-- 9. Inventory
CREATE TABLE `inventory_categories` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL
);

CREATE TABLE `inventory_items` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `category_id` CHAR(36) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `code` VARCHAR(255) NOT NULL,
    `unit` VARCHAR(255) NOT NULL,
    `stock` INT NOT NULL,
    `min_stock` INT NOT NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    UNIQUE (`code`),
    FOREIGN KEY (`category_id`) REFERENCES `inventory_categories` (`id`) ON DELETE CASCADE
);

CREATE TABLE `inventory_transactions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `item_id` CHAR(36) NOT NULL,
    `type` ENUM('in', 'out') NOT NULL,
    `quantity` INT NOT NULL,
    `description` TEXT NULL,
    `staff_id` CHAR(36) NOT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
);

-- 10. Financial
CREATE TABLE `payment_types` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `is_bpjs` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL
);

CREATE TABLE `payments` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `registration_id` CHAR(36) NOT NULL,
    `payment_type_id` CHAR(36) NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `notes` TEXT NULL,
    `staff_id` CHAR(36) NOT NULL,
    `created_at` TIMESTAMP NULL,
    `updated_at` TIMESTAMP NULL,
    FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`payment_type_id`) REFERENCES `payment_types` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
);