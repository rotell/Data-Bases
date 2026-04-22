DROP PROCEDURE IF EXISTS schedule_visit_for_pet(INT, VARCHAR, TIMESTAMP, INOUT INT, INOUT INT);
DROP PROCEDURE IF EXISTS add_client_with_pet(
    VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, DECIMAL, INOUT INT, INOUT INT, INOUT REFCURSOR
);


-- Procedure 1. Match a doctor and create a visit
CREATE OR REPLACE PROCEDURE schedule_visit_for_pet(
    IN p_pet_id INT,
    IN p_specialization_name VARCHAR(100),
    IN p_desired_datetime TIMESTAMP,
    INOUT p_doctor_id INT DEFAULT NULL,
    INOUT p_visit_id INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_species_id INT;
    v_matching_doctors_count INT;
BEGIN
    SELECT species_id
    INTO v_species_id
    FROM Pet
    WHERE pet_id = p_pet_id;

    IF v_species_id IS NULL THEN
        RAISE EXCEPTION 'Pet with id % does not exist', p_pet_id;
    END IF;

    SELECT COUNT(*)
    INTO v_matching_doctors_count
    FROM Doctor d
    JOIN Specialization s ON s.specialization_id = d.specialization_id
    WHERE d.species_id = v_species_id AND LOWER(s.specialization_name) = LOWER(p_specialization_name);

    IF v_matching_doctors_count = 0 THEN
        RAISE EXCEPTION
        'No doctors found for pet_id %, species_id %, specialization %', p_pet_id, v_species_id, p_specialization_name;
    END IF;

    SELECT d.doctor_id
    INTO p_doctor_id
    FROM Doctor d
    JOIN Specialization s ON s.specialization_id = d.specialization_id
    WHERE d.species_id = v_species_id AND LOWER(s.specialization_name) = LOWER(p_specialization_name)
      AND NOT EXISTS (
          SELECT 1
          FROM Visit v
          WHERE v.doctor_id = d.doctor_id AND v.status <> 'cancelled'
            AND v.visit_date BETWEEN p_desired_datetime - INTERVAL '15 minutes'
                                AND p_desired_datetime + INTERVAL '15 minutes'
      )
    ORDER BY d.doctor_id
    LIMIT 1;

    IF p_doctor_id IS NULL THEN
        RAISE EXCEPTION
        'Doctors with specialization % for pet_id % exist, but all are busy at %', p_specialization_name, p_pet_id, p_desired_datetime;
    END IF;

    INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
    VALUES (p_doctor_id, p_pet_id, p_desired_datetime, 'scheduled')
    RETURNING visit_id INTO p_visit_id;

    RAISE NOTICE 'Visit created: visit_id=%, doctor_id=%', p_visit_id, p_doctor_id;
END;
$$;

-- CALL schedule_visit_for_pet(
--     1,
--     'Surgery',
--     TIMESTAMP '2026-05-10 12:00:00',
--     NULL,
--     NULL
-- );

-- Procedure 2. Add a client with a pet and return available services
CREATE OR REPLACE PROCEDURE add_client_with_pet(
    IN p_passport VARCHAR(10),
    IN p_full_name VARCHAR(100),
    IN p_pet_nickname VARCHAR(100),
    IN p_species_name VARCHAR(100),
    IN p_phone VARCHAR(12) DEFAULT NULL,
    IN p_gender VARCHAR(1) DEFAULT NULL,
    IN p_pet_age INT DEFAULT NULL,
    IN p_pet_weight DECIMAL(5,2) DEFAULT NULL,
    INOUT p_client_id INT DEFAULT NULL,
    INOUT p_pet_id INT DEFAULT NULL,
    INOUT p_services_cursor REFCURSOR DEFAULT 'available_services'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_species_id INT;
BEGIN
    SELECT species_id
    INTO v_species_id
    FROM Species
    WHERE LOWER(species_name) = LOWER(p_species_name)
    ORDER BY species_id
    LIMIT 1;

    IF v_species_id IS NULL THEN
        RAISE EXCEPTION 'Species % does not exist', p_species_name;
    END IF;

    INSERT INTO Client (passport, full_name, phone, gender)
    VALUES (p_passport, p_full_name, p_phone, p_gender)
    RETURNING client_id INTO p_client_id;

    INSERT INTO Pet (client_id, species_id, nickname, age, weight)
    VALUES (p_client_id, v_species_id, p_pet_nickname, p_pet_age, p_pet_weight)
    RETURNING pet_id INTO p_pet_id;

    OPEN p_services_cursor FOR
        SELECT service_name, price
        FROM Service
        ORDER BY service_name;

    RAISE NOTICE 'Client created: client_id=%, pet created: pet_id=%', p_client_id, p_pet_id;
END;
$$;

-- BEGIN;
-- CALL add_client_with_pet(
--     '123456781',
--     'Ivan Ivanov',
--     'Rex',
--     'Dog'
-- );
-- FETCH ALL FROM available_services;
-- COMMIT;

-- BEGIN;
-- CALL add_client_with_pet(
--     '1234567892',
--     'Anna Petrova',
--     'Murka',
--     'Cat',
--     '+79990000002',
--     'F',
--     4,
--     3.80
-- );
-- FETCH ALL FROM available_services;
-- COMMIT;
