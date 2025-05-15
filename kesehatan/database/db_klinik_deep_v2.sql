-- Enable UUID extension for uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Define custom ENUM types to avoid conflicts
CREATE TYPE gender_type AS ENUM ('male', 'female', 'other');
CREATE TYPE blood_type AS ENUM ('A', 'B', 'AB', 'O');
CREATE TYPE rh_blood_type AS ENUM ('+', '-');
CREATE TYPE marital_status_type AS ENUM ('single', 'married', 'divorced', 'widowed');
CREATE TYPE history_type AS ENUM ('allergy', 'disease', 'surgery', 'medication', 'other');
CREATE TYPE severity_type AS ENUM ('mild', 'moderate', 'severe');
CREATE TYPE insurance_type AS ENUM ('bpjs', 'private', 'corporate', 'other');
CREATE TYPE leave_type AS ENUM ('sick', 'vacation', 'personal', 'other');
CREATE TYPE leave_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE day_of_week AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
CREATE TYPE appointment_source AS ENUM ('walk-in', 'online', 'phone', 'other');
CREATE TYPE queue_status AS ENUM ('waiting', 'in_progress', 'completed', 'cancelled', 'no_show');
CREATE TYPE priority_level AS ENUM ('normal', 'high', 'emergency');
CREATE TYPE diagnosis_type AS ENUM ('primary', 'secondary', 'differential');
CREATE TYPE medication_form AS ENUM ('tablet', 'capsule', 'syrup', 'injection', 'ointment', 'other');
CREATE TYPE inventory_item_type AS ENUM ('medicine', 'medical_supply', 'equipment', 'other');
CREATE TYPE transaction_type AS ENUM ('purchase', 'sale', 'adjustment', 'transfer_in', 'transfer_out', 'return', 'waste');
CREATE TYPE prescription_status AS ENUM ('draft', 'active', 'completed', 'cancelled');
CREATE TYPE billing_item_type AS ENUM ('service', 'medication', 'other');

-- Core Tables
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    last_login_ip VARCHAR(45) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    guard_name VARCHAR(255) DEFAULT 'web',
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    guard_name VARCHAR(255) DEFAULT 'web',
    description TEXT NULL,
    group_name VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE model_has_roles (
    role_id UUID NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id UUID NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, model_id, model_type)
);

CREATE TABLE model_has_permissions (
    permission_id UUID NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id UUID NOT NULL,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (permission_id, model_id, model_type)
);

CREATE TABLE role_has_permissions (
    permission_id UUID NOT NULL,
    role_id UUID NOT NULL,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (permission_id, role_id)
);

-- Clinic Management
CREATE TABLE clinics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    province_id VARCHAR(5) NOT NULL,
    city_id VARCHAR(5) NOT NULL,
    district_id VARCHAR(8) NOT NULL,
    village_id VARCHAR(10) NOT NULL,
    postal_code VARCHAR(10) NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NULL,
    logo_url VARCHAR(255) NULL,
    license_number VARCHAR(100) NULL,
    tax_id VARCHAR(100) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clinic_branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    province_id VARCHAR(5) NOT NULL,
    city_id VARCHAR(5) NOT NULL,
    district_id VARCHAR(8) NOT NULL,
    village_id VARCHAR(10) NOT NULL,
    postal_code VARCHAR(10) NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_main_branch BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
);

CREATE TABLE clinic_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    setting_key VARCHAR(255) NOT NULL,
    setting_value TEXT NULL,
    setting_group VARCHAR(100) NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    UNIQUE (clinic_id, setting_key)
);

-- Patient Management
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    medical_record_number VARCHAR(50) NOT NULL,
    nik VARCHAR(16) NULL,
    name VARCHAR(255) NOT NULL,
    birth_place VARCHAR(100) NULL,
    birth_date DATE NULL,
    gender gender_type NULL,
    blood_type blood_type NULL,
    rh_blood_type rh_blood_type NULL,
    address TEXT NULL,
    province_id VARCHAR(5) NULL,
    city_id VARCHAR(5) NULL,
    district_id VARCHAR(8) NULL,
    village_id VARCHAR(10) NULL,
    postal_code VARCHAR(10) NULL,
    phone VARCHAR(20) NULL,
    email VARCHAR(255) NULL,
    religion VARCHAR(50) NULL,
    marital_status marital_status_type NULL,
    education VARCHAR(100) NULL,
    occupation VARCHAR(100) NULL,
    family_name VARCHAR(255) NULL,
    family_relationship VARCHAR(100) NULL,
    family_phone VARCHAR(20) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    UNIQUE (clinic_id, medical_record_number)
);

CREATE TABLE patient_medical_histories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL,
    history_type history_type NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    severity severity_type NULL,
    is_chronic BOOLEAN DEFAULT FALSE,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

CREATE TABLE patient_insurance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL,
    insurance_type insurance_type NOT NULL,
    insurance_number VARCHAR(100) NOT NULL,
    insurance_name VARCHAR(255) NULL,
    holder_name VARCHAR(255) NULL,
    holder_relationship VARCHAR(100) NULL,
    expiry_date DATE NULL,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

-- Staff Management
CREATE TABLE staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NULL,
    clinic_id UUID NOT NULL,
    employee_number VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    specialization VARCHAR(255) NULL,
    position VARCHAR(100) NOT NULL,
    nik VARCHAR(16) NULL,
    birth_place VARCHAR(100) NULL,
    birth_date DATE NULL,
    gender gender_type NULL,
    address TEXT NULL,
    province_id VARCHAR(5) NULL,
    city_id VARCHAR(5) NULL,
    district_id VARCHAR(8) NULL,
    village_id VARCHAR(10) NULL,
    postal_code VARCHAR(10) NULL,
    phone VARCHAR(20) NULL,
    email VARCHAR(255) NULL,
    join_date DATE NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    UNIQUE (clinic_id, employee_number)
);

CREATE TABLE staff_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL,
    clinic_branch_id UUID NOT NULL,
    day_of_week day_of_week NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_recurring BOOLEAN DEFAULT TRUE,
    valid_from DATE NULL,
    valid_to DATE NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_branch_id) REFERENCES clinic_branches(id) ON DELETE CASCADE
);

CREATE TABLE staff_leave (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL,
    leave_type leave_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NULL,
    status leave_status DEFAULT 'pending',
    approved_by UUID NULL,
    approved_at TIMESTAMP NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES staff(id) ON DELETE SET NULL
);

-- Medical Services
CREATE TABLE service_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
);

CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    category_id UUID NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    duration INT NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_online_booking_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES service_categories(id) ON DELETE SET NULL,
    UNIQUE (clinic_id, code)
);

CREATE TABLE doctor_specializations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staff_service_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL,
    service_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    UNIQUE (staff_id, service_id)
);

-- Appointment & Queue
CREATE TABLE appointment_status (
    code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    color VARCHAR(20) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    clinic_branch_id UUID NOT NULL,
    patient_id UUID NOT NULL,
    service_id UUID NOT NULL,
    staff_id UUID NULL,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status_code VARCHAR(50) NOT NULL,
    source appointment_source NOT NULL,
    notes TEXT NULL,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_pattern VARCHAR(100) NULL,
    cancellation_reason TEXT NULL,
    created_by UUID NULL,
    updated_by UUID NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_branch_id) REFERENCES clinic_branches(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE SET NULL,
    FOREIGN KEY (status_code) REFERENCES appointment_status(code) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES staff(id) ON DELETE SET NULL
);

CREATE TABLE queues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    clinic_branch_id UUID NOT NULL,
    patient_id UUID NOT NULL,
    appointment_id UUID NULL,
    service_id UUID NOT NULL,
    staff_id UUID NULL,
    queue_number VARCHAR(20) NOT NULL,
    queue_date DATE NOT NULL,
    estimated_time TIME NULL,
    status queue_status NOT NULL DEFAULT 'waiting',
    priority_level priority_level DEFAULT 'normal',
    notes TEXT NULL,
    called_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_branch_id) REFERENCES clinic_branches(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE SET NULL
);

-- Medical Records
CREATE TABLE medical_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    patient_id UUID NOT NULL,
    queue_id UUID NULL,
    staff_id UUID NOT NULL,
    record_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subjective TEXT NULL,
    objective TEXT NULL,
    assessment TEXT NULL,
    plan TEXT NULL,
    notes TEXT NULL,
    follow_up_date DATE NULL,
    follow_up_notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (queue_id) REFERENCES queues(id) ON DELETE SET NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE RESTRICT
);

CREATE TABLE medical_record_diagnoses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medical_record_id UUID NOT NULL,
    diagnosis_code VARCHAR(50) NOT NULL,
    diagnosis_name VARCHAR(255) NOT NULL,
    diagnosis_type diagnosis_type DEFAULT 'primary',
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE
);

CREATE TABLE medical_record_procedures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medical_record_id UUID NOT NULL,
    procedure_code VARCHAR(50) NOT NULL,
    procedure_name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    result TEXT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE
);

-- Pharmacy & Inventory
CREATE TABLE medication_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE
);

CREATE TABLE medications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    category_id UUID NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255) NULL,
    manufacturer VARCHAR(255) NULL,
    form medication_form NOT NULL,
    unit VARCHAR(50) NOT NULL,
    content VARCHAR(100) NULL,
    barcode VARCHAR(100) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_pharmaceutical BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCE medication_categories(id) ON DELETE SET NULL,
    UNIQUE (clinic_id, code)
);

CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    medication_id UUID NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    type inventory_item_type NOT NULL,
    unit VARCHAR(50) NOT NULL,
    min_stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE SET NULL,
    UNIQUE (clinic_id, code)
);

CREATE TABLE inventory_stocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_branch_id UUID NOT NULL,
    inventory_item_id UUID NOT NULL,
    batch_number VARCHAR(100) NULL,
    expiry_date DATE NULL,
    current_quantity INT NOT NULL DEFAULT 0,
    last_purchase_price DECIMAL(15, 2) NULL,
    last_restock_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_branch_id) REFERENCES clinic_branches(id) ON DELETE CASCADE,
    FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id) ON DELETE CASCADE
);

CREATE TABLE inventory_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_branch_id UUID NOT NULL,
    inventory_item_id UUID NOT NULL,
    transaction_type transaction_type NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15, 2) NULL,
    total_price DECIMAL(15, 2) NULL,
    batch_number VARCHAR(100) NULL,
    expiry_date DATE NULL,
    reference_id UUID NULL,
    reference_type VARCHAR(100) NULL,
    notes TEXT NULL,
    created_by UUID NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_branch_id) REFERENCES clinic_branches(id) ON DELETE CASCADE,
    FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL
);

CREATE TABLE prescriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medical_record_id UUID NOT NULL,
    clinic_branch_id UUID NOT NULL,
    prescription_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT NULL,
    status prescription_status DEFAULT 'draft',
    created_by UUID NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE,
    FOREIGN KEY (clinic_branch_id) REFERENCES clinic_branches(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL
);

CREATE TABLE prescription_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prescription_id UUID NOT NULL,
    medication_id UUID NOT NULL,
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    duration VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    notes TEXT NULL,
    is_dispensed BOOLEAN DEFAULT FALSE,
    dispensed_at TIMESTAMP NULL,
    dispensed_by UUID NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE RESTRICT,
    FOREIGN KEY (dispensed_by) REFERENCES staff(id) ON DELETE SET NULL
);

-- Billing & Payments
CREATE TABLE billing_status (
    code VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE billings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    patient_id UUID NOT NULL,
    medical_record_id UUID NULL,
    billing_number VARCHAR(50) NOT NULL,
    billing_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date TIMESTAMP NULL,
    status_code VARCHAR(50) NOT NULL,
    subtotal DECIMAL(15, 2) NOT NULL,
    discount DECIMAL(15, 2) DEFAULT 0,
    tax DECIMAL(15, 2) DEFAULT 0,
    total DECIMAL(15, 2) NOT NULL,
    notes TEXT NULL,
    created_by UUID NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE SET NULL,
    FOREIGN KEY (status_code) REFERENCES billing_status(code) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL,
    UNIQUE (clinic_id, billing_number)
);

CREATE TABLE billing_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    billing_id UUID NOT NULL,
    item_type billing_item_type NOT NULL,
    item_id UUID NULL,
    item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(15, 2) NOT NULL,
    discount DECIMAL(15, 2) DEFAULT 0,
    total_price DECIMAL(15, 2) NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (billing_id) REFERENCES billings(id) ON DELETE CASCADE
);

CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clinic_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (clinic_id) REFERENCES clinics(id) ON DELETE CASCADE,
    UNIQUE (clinic_id, code)
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    billing_id UUID NOT NULL,
    payment_method_id UUID NOT NULL,
    payment_number VARCHAR(50) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(15, 2) NOT NULL,
    reference_number VARCHAR(100) NULL,
    notes TEXT NULL,
    created_by UUID NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (billing_id) REFERENCES billings(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL
);

-- Additional Features
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(100) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_id UUID NULL,
    related_type VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NULL,
    event VARCHAR(255) NOT NULL,
    auditable_type VARCHAR(255) NOT NULL,
    auditable_id UUID NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    url TEXT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    tags VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value TEXT NULL,
    setting_group VARCHAR(100) NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

CREATE INDEX idx_patients_clinic_id ON patients(clinic_id);
CREATE INDEX idx_patients_medical_record_number ON patients(medical_record_number);
CREATE INDEX idx_patients_nik ON patients(nik);
CREATE INDEX idx_patients_name ON patients(name);

CREATE INDEX idx_appointments_clinic_id ON appointments(clinic_id);
CREATE INDEX idx_appointments_patient_id ON appointments(patient_id);
CREATE INDEX idx_appointments_staff_id ON appointments(staff_id);
CREATE INDEX idx_appointments_status_code ON appointments(status_code);
CREATE INDEX idx_appointments_date_time ON appointments(appointment_date, start_time);

CREATE INDEX idx_medical_records_patient_id ON medical_records(patient_id);
CREATE INDEX idx_medical_records_staff_id ON medical_records(staff_id);

CREATE INDEX idx_inventory_items_clinic_id ON inventory_items(clinic_id);
CREATE INDEX idx_inventory_stocks_clinic_branch_id ON inventory_stocks(clinic_branch_id);
CREATE INDEX idx_inventory_stocks_expiry_date ON inventory_stocks(expiry_date);

CREATE INDEX idx_billings_patient_id ON billings(patient_id);
CREATE INDEX idx_billings_status_code ON billings(status_code);
CREATE INDEX idx_billings_billing_number ON billings(billing_number);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_auditable ON audit_logs(auditable_type, auditable_id);