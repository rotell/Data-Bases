-- Пересоздание схемы
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;


CREATE TABLE Client (
    client_id SERIAL PRIMARY KEY,
    passport VARCHAR(10) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(12),
    gender VARCHAR(1) CHECK (gender IN ('M','F'))
);

CREATE TABLE Species (
    species_id SERIAL PRIMARY KEY,
    species_name VARCHAR(100) NOT NULL,
    description TEXT,
    latin_name VARCHAR(100)
);

CREATE TABLE Pet (
    pet_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    species_id INT NOT NULL,
    nickname VARCHAR(100) NOT NULL,
    age INT CHECK (age >= 0),
    weight DECIMAL(5,2) CHECK (weight > 0),

    CONSTRAINT fk_pet_client
        FOREIGN KEY (client_id)
        REFERENCES Client(client_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pet_species
        FOREIGN KEY (species_id)
        REFERENCES Species(species_id)
);

CREATE TABLE Vaccine (
    vaccine_id SERIAL PRIMARY KEY,
    vaccine_name VARCHAR(100) NOT NULL UNIQUE,
    indications TEXT,
    contraindications TEXT
);

CREATE TABLE Pet_Vaccine (
    pet_id INT,
    vaccine_id INT,
    vaccination_date DATE NOT NULL,

    PRIMARY KEY (pet_id, vaccine_id),

    FOREIGN KEY (pet_id)
        REFERENCES Pet(pet_id)
        ON DELETE RESTRICT,

    FOREIGN KEY (vaccine_id)
        REFERENCES Vaccine(vaccine_id)
);

CREATE TABLE Employee (
    employee_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    passport VARCHAR(10) UNIQUE NOT NULL,
    phone VARCHAR(12),
    role VARCHAR(20) CHECK (role IN ('registrar','administrator','doctor'))
);

CREATE TABLE Specialization (
    specialization_id SERIAL PRIMARY KEY,
    specialization_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Doctor (
    doctor_id SERIAL PRIMARY KEY,
    employee_id INT UNIQUE NOT NULL,
    specialization_id INT NOT NULL,

    FOREIGN KEY (employee_id)
        REFERENCES Employee(employee_id)
        ON DELETE CASCADE,

    FOREIGN KEY (specialization_id)
        REFERENCES Specialization(specialization_id)
);

CREATE TABLE Visit (
    visit_id SERIAL PRIMARY KEY,
    doctor_id INT NOT NULL,
    pet_id INT NOT NULL,
    visit_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled','completed','cancelled')),

    FOREIGN KEY (doctor_id)
        REFERENCES Doctor(doctor_id)
        ON DELETE RESTRICT,

    FOREIGN KEY (pet_id)
        REFERENCES Pet(pet_id)
        ON DELETE RESTRICT
);

CREATE TABLE Service (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    price INT NOT NULL
);

CREATE TABLE Visit_Service (
    visit_id INT NOT NULL,
    service_id INT NOT NULL,

    PRIMARY KEY (visit_id, service_id),

    FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,

    FOREIGN KEY (service_id)
        REFERENCES Service(service_id)
);

CREATE TABLE Prescription (
    prescription_id SERIAL PRIMARY KEY,
    visit_id INT NOT NULL,
    prescription_text TEXT,
    medication VARCHAR(100),

    FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE
);

CREATE TABLE Bill (
    bill_id SERIAL PRIMARY KEY,
    visit_id INT NOT NULL UNIQUE,
    amount INT NOT NULL CHECK (amount >= 0),
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE
);

CREATE TABLE Indicator (
    indicator_id SERIAL PRIMARY KEY,
    indicator_name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(20),
    min_value DECIMAL(10,4),
    max_value DECIMAL(10,4),
    CHECK (min_value IS NULL OR max_value IS NULL OR min_value <= max_value)

);

CREATE TABLE Observation (
    observation_id SERIAL PRIMARY KEY,
    pet_id INT NOT NULL,
    indicator_id INT NOT NULL,
    value DECIMAL(10,4) NOT NULL,
    observation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (pet_id)
        REFERENCES Pet(pet_id)
        ON DELETE RESTRICT,

    FOREIGN KEY (indicator_id)
        REFERENCES Indicator(indicator_id)
);

CREATE TABLE Event_Log (
    event_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    visit_id INT,
    pet_id INT,
    bill_id INT,
    event_type VARCHAR(100),
    event_time TIMESTAMP NOT NULL,
    description TEXT,

    FOREIGN KEY (employee_id)
        REFERENCES Employee(employee_id),

    FOREIGN KEY (visit_id)
        REFERENCES Visit(visit_id)
        ON DELETE CASCADE,

    FOREIGN KEY (bill_id)
        REFERENCES Bill(bill_id)
        ON DELETE CASCADE,

    FOREIGN KEY (pet_id)
        REFERENCES Pet(pet_id)
        ON DELETE RESTRICT
);
