-- Species
INSERT INTO Species (species_name, description, latin_name) VALUES
('Dog', 'Domestic dog', 'Labrador retriever'),
('Dog', 'Domestic dog', 'Canis lupus familiaris'),
('Cat', 'Domestic cat', 'Felis silvestris catus'),
('Parrot', 'Bird species', 'Ara');

-- Clients
INSERT INTO Client (passport, full_name, phone, gender) VALUES
('4519123456', 'Ivan Petrov', '89161870709', 'M'),
('7689098765', 'Anna Smirnova', '+79166766561', 'F');

-- Pets
INSERT INTO Pet (client_id, species_id, nickname, age, weight) VALUES
(1, 1, 'Rex', 5, 24.5),
(2, 3, 'Barsik', 3, 4.2);

-- Vaccines
INSERT INTO Vaccine (vaccine_name, indications) VALUES
('Rabies', 'Prevention of rabies'),
('Distemper', 'Prevention of distemper');

-- Pet_Vaccine
INSERT INTO Pet_Vaccine (pet_id, vaccine_id, vaccination_date) VALUES
(1, 1, '2025-01-10'),
(2, 2, '2025-02-15');

-- Employees
INSERT INTO Employee (full_name, passport, phone, role) VALUES
('Sergey Ivanov', '4519888777', '88008789087', 'doctor'),
('Maria Antonova', '6898767667', '84957168225', 'registrar');

-- Specializations
INSERT INTO Specialization (specialization_name) VALUES
('Surgery'),
('Therapy');

-- Doctor
INSERT INTO Doctor (employee_id, specialization_id) VALUES
(1, 1);

-- Service
INSERT INTO Service (service_name, price) VALUES
('General checkup', 1500),
('Vaccination', 1000);

-- Visit
INSERT INTO Visit (doctor_id, pet_id, visit_date, status) VALUES
(1, 1, '2026-04-01 10:00:00', 'completed');

-- Visit_Service
INSERT INTO Visit_Service (visit_id, service_id) VALUES
(1, 1),
(1, 2);

-- Bill
INSERT INTO Bill (visit_id, amount, is_paid) VALUES
(1, 2500.00, TRUE);

-- Prescription
INSERT INTO Prescription (visit_id, prescription_text, medication) VALUES
(1, 'Take vitamins for 7 days', 'Vitamin Complex');

-- Indicator
INSERT INTO Indicator (indicator_name, unit, min_value, max_value) VALUES
('Temperature', 'C', 35.0, 37.0),
('Red blood cells', 'C', 7, 12);

-- Observation
INSERT INTO Observation (pet_id, indicator_id, value) VALUES
(1, 1, 36.5);

-- Event_Logp
INSERT INTO Event_Log (employee_id, visit_id, pet_id, bill_id, event_type, event_time, description) VALUES
(2, 1, 1, NULL, 'visit_created', '2026-04-01 9:20:00', 'Visit was created by registrar');