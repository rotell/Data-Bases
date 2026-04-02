-- Species
INSERT INTO Species (species_name, description, latin_name) VALUES
-- ('Dog', 'Domestic dog', 'Labrador retriever'),
-- ('Dog', 'Domestic dog', 'Canis lupus familiaris'),
-- ('Cat', 'Domestic cat', 'Felis silvestris catus'),
-- ('Parrot', 'Bird species', 'Ara'),
-- ('Parrot', 'African grey parrot', 'Psittacus erithacus'),
-- ('Parrot', 'Macaw', 'Ara macao'),
-- ('Dog', 'German shepherd', 'Canis lupus familiaris'),
-- ('Cat', 'Siamese cat', 'Felis silvestris catus'),
-- ('Lizard', 'Bearded dragon', 'Pogona vitticeps'),
-- ('Spider', 'Tarantula', 'Theraphosidae'),
-- ('Chinchilla', 'Domestic chinchilla', 'Chinchilla lanigera'),
-- ('Gerbil', 'Mongolian gerbil', 'Meriones unguiculatus'),
-- ('Rabbit', 'Domestic rabbit', 'Oryctolagus cuniculus'),
-- ('Ferret', 'Domestic ferret', 'Mustela putorius furo'),
-- ('Hamster', 'Syrian hamster', 'Mesocricetus auratus'),
-- ('Guinea pig', 'Domestic guinea pig', 'Cavia porcellus'),
-- ('Bird', 'Budgerigar', 'Melopsittacus undulatus'),
-- ('Turtle', 'Red-eared slider', 'Trachemys scripta elegans'),
-- ('Fish', 'Goldfish', 'Carassius auratus'),
-- ('Snake', 'Ball python', 'Python regius');
-- Птицы
('Bird', 'Chicken', 'Gallus gallus domesticus'),
('Bird', 'Duck', 'Anas platyrhynchos domesticus'),
('Bird', 'Parrot - African Grey', 'Psittacus erithacus'),
('Bird', 'Parrot - Macaw', 'Ara macao'),
('Bird', 'Budgerigar', 'Melopsittacus undulatus'),
('Bird', 'Canary', 'Serinus canaria'),
('Bird', 'Cockatiel', 'Nymphicus hollandicus'),

-- Собаки  
('Dog', 'Labrador Retriever', 'Canis lupus familiaris'),
('Dog', 'German Shepherd', 'Canis lupus familiaris'),
('Dog', 'Golden Retriever', 'Canis lupus familiaris'),
('Dog', 'Poodle', 'Canis lupus familiaris'),
('Dog', 'Bulldog', 'Canis lupus familiaris'),

-- Кошки
('Cat', 'Siamese', 'Felis silvestris catus'),
('Cat', 'Maine Coon', 'Felis silvestris catus'),
('Cat', 'Persian', 'Felis silvestris catus'),
('Cat', 'Abyssinian', 'Felis silvestris catus'),

-- Грызуны
('Rodent', 'Guinea Pig', 'Cavia porcellus'),
('Rodent', 'Hamster - Syrian', 'Mesocricetus auratus'),
('Rodent', 'Gerbil - Mongolian', 'Meriones unguiculatus'),
('Rodent', 'Rat - Fancy', 'Rattus norvegicus'),
('Rodent', 'Mouse - Fancy', 'Mus musculus'),
('Rodent', 'Chinchilla', 'Chinchilla lanigera'),

-- Зайцеобразные
('Rabbit', 'Dutch Rabbit', 'Oryctolagus cuniculus domesticus'),
('Rabbit', 'Lionhead', 'Oryctolagus cuniculus domesticus'),

-- Рептилии
('Reptile', 'Bearded Dragon', 'Pogona vitticeps'),
('Reptile', 'Ball Python', 'Python regius'),
('Reptile', 'Red-eared Slider', 'Trachemys scripta elegans'),
('Reptile', 'Corn Snake', 'Pantherophis guttatus'),

-- Паукообразные
('Arachnid', 'Tarantula - Chilean Rose', 'Grammostola rosea'),
('Arachnid', 'Tarantula - Mexican Redknee', 'Brachypelma smithi'),

-- Рыбы
('Fish', 'Goldfish', 'Carassius auratus'),
('Fish', 'Betta', 'Betta splendens'),
('Fish', 'Guppy', 'Poecilia reticulata'),

-- Хорьки
('Ferret', 'Standard', 'Mustela putorius furo');


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
('Therapy'),
('Cardiology'),
('Orthopedics'),
('Dermatology'),
('Dentistry'),
('Ophthalmology'),
('Neurology');

-- Doctor
INSERT INTO Doctor (employee_id, specialization_id, species_id) VALUES
(1, 1, 1);

-- Service
INSERT INTO Service (service_name, price) VALUES
('General checkup', 1500),
('Vaccination', 1000),
('X-ray', 2500),
('Blood test', 1200),
('Ultrasound', 2000),
('Dental cleaning', 3500),
('Microchip implantation', 1800),
('Grooming', 2200),
('Orthopedic consultation', 2800),
('Dermatology treatment', 2000),
('Dental extraction', 4500),
('Surgery', 8000);

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
('Weight', 'kg', 1, 100),
('Heart rate', 'bpm', 60, 180),
('Oxygen saturation', '%', 95, 100),
('Respiration rate', 'rpm', 10, 40),
('Red blood cells', '10^12/L', 7, 12),
('White blood cells', '10^9/L', 4, 15),
('Platelets', '10^9/L', 150, 400),
('Glucose', 'mmol/L', 3, 8),
('Hemoglobin', 'g/L', 100, 180),
('Creatinine', 'umol/L', 40, 160),
('Bilirubin', 'umol/L', 0, 10),
('Cholesterol', 'mmol/L', 2.5, 7.5),
('Calcium', 'mmol/L', 2.0, 3.0),
('Phosphorus', 'mmol/L', 0.8, 2.0),
('Blood pressure', 'mmHg', 80, 160);

-- Observation
INSERT INTO Observation (pet_id, indicator_id, value) VALUES
(1, 1, 36.5);

-- Event_Log
INSERT INTO Event_Log (employee_id, visit_id, pet_id, bill_id, event_type, event_time, description) VALUES
(2, 1, 1, NULL, 'visit_created', '2026-04-01 9:20:00', 'Visit was created by registrar');