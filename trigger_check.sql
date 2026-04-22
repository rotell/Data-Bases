-- Trigger 1:
DO $$
DECLARE
    v_doctor_id INT;
    v_pet_id INT;
    v_visit_id INT;
BEGIN
    SELECT d.doctor_id, p.pet_id
    INTO v_doctor_id, v_pet_id
    FROM Doctor d
    JOIN Pet p ON p.species_id = d.species_id
    LIMIT 1;

    INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
    VALUES (v_doctor_id, v_pet_id, CURRENT_TIMESTAMP, 'scheduled')
    RETURNING visit_id INTO v_visit_id;

    RAISE NOTICE 'Trigger 1 success: visit % created', v_visit_id;

    DELETE FROM Visit WHERE visit_id = v_visit_id;
END $$;


-- Trigger 1: error
DO $$
DECLARE
    v_doctor_id INT;
    v_pet_id INT;
    v_doctor_species_id INT;
BEGIN
    SELECT doctor_id, species_id
    INTO v_doctor_id, v_doctor_species_id
    FROM Doctor
    LIMIT 1;

    SELECT pet_id
    INTO v_pet_id
    FROM Pet
    WHERE species_id <> v_doctor_species_id
    LIMIT 1;

    BEGIN
        INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
        VALUES (v_doctor_id, v_pet_id, CURRENT_TIMESTAMP, 'scheduled');

        RAISE EXCEPTION 'Trigger 1 error case failed: insert unexpectedly succeeded';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Trigger 1 expected error: %', SQLERRM;
    END;
END $$;


-- Trigger 2:
DO $$
DECLARE
    v_doctor_id INT;
    v_pet_id INT;
    v_visit_id INT;
    v_service_id INT;
BEGIN
    SELECT d.doctor_id, p.pet_id
    INTO v_doctor_id, v_pet_id
    FROM Doctor d
    JOIN Pet p ON p.species_id = d.species_id
    LIMIT 1;

    SELECT service_id
    INTO v_service_id
    FROM Service
    LIMIT 1;

    INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
    VALUES (v_doctor_id, v_pet_id, CURRENT_TIMESTAMP, 'scheduled')
    RETURNING visit_id INTO v_visit_id;

    INSERT INTO Visit_Service (visit_id, service_id)
    VALUES (v_visit_id, v_service_id);

    RAISE NOTICE 'Trigger 2 success: service % added to visit %', v_service_id, v_visit_id;

    DELETE FROM Visit WHERE visit_id = v_visit_id;
END $$;


-- Trigger 2: error
DO $$
DECLARE
    v_doctor_id INT;
    v_pet_id INT;
    v_visit_id INT;
    v_service_id INT;
BEGIN
    SELECT d.doctor_id, p.pet_id
    INTO v_doctor_id, v_pet_id
    FROM Doctor d
    JOIN Pet p ON p.species_id = d.species_id
    LIMIT 1;

    SELECT service_id
    INTO v_service_id
    FROM Service
    LIMIT 1;

    INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
    VALUES (v_doctor_id, v_pet_id, CURRENT_TIMESTAMP, 'cancelled')
    RETURNING visit_id INTO v_visit_id;

    BEGIN
        INSERT INTO Visit_Service (visit_id, service_id)
        VALUES (v_visit_id, v_service_id);

        RAISE EXCEPTION 'Trigger 2 error case failed: insert unexpectedly succeeded';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Trigger 2 expected error: %', SQLERRM;
    END;

    DELETE FROM Visit WHERE visit_id = v_visit_id;
END $$;
