-- Enable extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('patient', 'doctor', 'pharmacist', 'admin', 'nurse') NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_email ON users(email);

-- Patients table
CREATE TABLE patients (
    patient_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    bpjs_number VARCHAR(20) UNIQUE,
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other'),
    address TEXT,
    allergies TEXT[],
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
);

-- Doctors table
CREATE TABLE doctors (
    doctor_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    specialization VARCHAR(100),
    license_number VARCHAR(50) UNIQUE,
    clinic_id UUID,
    consultation_fee DECIMAL(10, 2)
);

-- Clinics table
CREATE TABLE clinics (
    clinic_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone_number VARCHAR(20),
    type ENUM('clinic', 'hospital') NOT NULL,
    location GEOGRAPHY(POINT)
);
CREATE INDEX idx_clinics_location ON clinics USING GIST (location);

-- Appointments table
CREATE TABLE appointments (
    appointment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(patient_id),
    doctor_id UUID REFERENCES doctors(doctor_id),
    clinic_id UUID REFERENCES clinics(clinic_id),
    appointment_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status ENUM('scheduled', 'completed', 'cancelled', 'pending') NOT NULL,
    type ENUM('in_person', 'teleconsultation'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_appointments_time ON appointments(appointment_time);

-- Medical Records table
CREATE TABLE medical_records (
    record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(patient_id),
    doctor_id UUID REFERENCES doctors(doctor_id),
    appointment_id UUID REFERENCES appointments(appointment_id),
    diagnosis TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_medical_records_patient ON medical_records(patient_id);

-- Prescriptions table
CREATE TABLE prescriptions (
    prescription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(patient_id),
    doctor_id UUID REFERENCES doctors(doctor_id),
    appointment_id UUID REFERENCES appointments(appointment_id),
    pharmacy_id UUID,
    medication_details JSONB,
    status ENUM('pending', 'fulfilled', 'cancelled'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Pharmacies table
CREATE TABLE pharmacies (
    pharmacy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone_number VARCHAR(20),
    location GEOGRAPHY(POINT)
);

-- Inventory table
CREATE TABLE inventory (
    inventory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pharmacy_id UUID REFERENCES pharmacies(pharmacy_id),
    clinic_id UUID REFERENCES clinics(clinic_id),
    item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    expiry_date DATE,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_inventory_expiry ON inventory(expiry_date);

-- Billing table
CREATE TABLE billing (
    bill_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(patient_id),
    appointment_id UUID REFERENCES appointments(appointment_id),
    total_amount DECIMAL(10, 2) NOT NULL,
    bpjs_coverage DECIMAL(10, 2),
    payment_status ENUM('pending', 'paid', 'failed') NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- BPJS Claims table
CREATE TABLE bpjs_claims (
    claim_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_id UUID REFERENCES billing(bill_id),
    patient_id UUID REFERENCES patients(patient_id),
    bpjs_number VARCHAR(20),
    claim_status ENUM('submitted', 'approved', 'rejected', 'pending'),
    claim_amount DECIMAL(10, 2),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Audit Logs table
CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key constraints for doctors
ALTER TABLE doctors ADD CONSTRAINT fk_doctors_clinic FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id);

-- Add foreign key for prescriptions
ALTER TABLE prescriptions ADD CONSTRAINT fk_prescriptions_pharmacy FOREIGN KEY (pharmacy_id) REFERENCES pharmacies(pharmacy_id);
