import random
from datetime import datetime, timedelta

import psycopg2


# ------------------------
# SETTINGS
# ------------------------

NUM_CLIENTS = 50
NUM_PETS = 250
NUM_EMPLOYEES = 20
MIN_DOCTORS = 10
NUM_VISITS = 250
OBS_PETS_LIMIT = 100
OBS_PER_INDICATOR = 10

VISIT_STATUSES = ["scheduled", "completed", "cancelled"]
VISIT_STATUS_WEIGHTS = [0.3, 0.55, 0.15]

PRESCRIPTIONS = [
    ("Rest and hydration for 5 days", "Supportive therapy"),
    ("Take vitamins for 7 days", "Vitamin complex"),
    ("Apply ointment twice daily", "Topical ointment"),
    ("Follow a light diet for 3 days", "Diet therapy"),
    ("Monitor temperature daily", "Home observation"),
]

# ------------------------

conn = psycopg2.connect(
    dbname="vet_clinic",
    user="postgres",
    password="sql",
    host="localhost",
    port="5432",
)

cur = conn.cursor()


def build_visit_datetime(status: str) -> datetime:
    """Generate dates that match the visit status."""
    now = datetime.now()

    if status == "scheduled":
        return now + timedelta(
            days=random.randint(1, 30),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
        )

    return now - timedelta(
        days=random.randint(1, 365),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
    )


# ------------------------
# Species
# ------------------------

cur.execute("SELECT species_id FROM Species")
species_ids = [row[0] for row in cur.fetchall()]

# ------------------------
# Other IDs
# ------------------------

cur.execute("SELECT indicator_id FROM Indicator")
indicator_ids = [row[0] for row in cur.fetchall()]

cur.execute("SELECT service_id, price FROM Service")
service_rows = cur.fetchall()
service_ids = [row[0] for row in service_rows]
service_prices = {service_id: float(price) for service_id, price in service_rows}

cur.execute("SELECT specialization_id FROM Specialization")
specialization_ids = [row[0] for row in cur.fetchall()]

# ------------------------
# Clients
# ------------------------

for i in range(NUM_CLIENTS):
    cur.execute(
        """
        INSERT INTO Client (passport, full_name, gender)
        VALUES (%s, %s, %s)
        """,
        (f"PP{i:07d}", f"Client {i}", random.choice(["M", "F"])),
    )

cur.execute("SELECT client_id FROM Client")
client_ids = [row[0] for row in cur.fetchall()]

# ------------------------
# Pets
# ------------------------

pet_species_map = {}

for i in range(NUM_PETS):
    species_id = random.choice(species_ids)

    cur.execute(
        """
        INSERT INTO Pet (client_id, species_id, nickname, age, weight)
        VALUES (%s, %s, %s, %s, %s)
        RETURNING pet_id
        """,
        (
            random.choice(client_ids),
            species_id,
            f"Pet_{i}",
            random.randint(1, 15),
            round(random.uniform(1.0, 40.0), 2),
        ),
    )

    pet_id = cur.fetchone()[0]
    pet_species_map[pet_id] = species_id

pet_ids = list(pet_species_map.keys())

# ------------------------
# Employees + Doctors
# ------------------------

doctor_employee_ids = []
roles = ["registrar", "administrator", "doctor"]

for i in range(NUM_EMPLOYEES):
    role = random.choice(roles)

    cur.execute(
        """
        INSERT INTO Employee (full_name, passport, phone, role)
        VALUES (%s, %s, %s, %s)
        RETURNING employee_id
        """,
        (
            f"Employee {i}",
            f"EMP{i:07d}",
            f"+7999000{i:03d}",
            role,
        ),
    )

    employee_id = cur.fetchone()[0]

    if role == "doctor":
        doctor_employee_ids.append(employee_id)

while len(doctor_employee_ids) < MIN_DOCTORS:
    cur.execute(
        """
        INSERT INTO Employee (full_name, passport, phone, role)
        VALUES (%s, %s, %s, %s)
        RETURNING employee_id
        """,
        (
            f"Doctor extra {len(doctor_employee_ids)}",
            f"DOCX{len(doctor_employee_ids):05d}",
            f"+7999111{len(doctor_employee_ids):03d}",
            "doctor",
        ),
    )
    doctor_employee_ids.append(cur.fetchone()[0])

doctor_ids = []
doctor_species_map = {}

for employee_id in doctor_employee_ids:
    species_id = random.choice(species_ids)

    cur.execute(
        """
        INSERT INTO Doctor (employee_id, specialization_id, species_id)
        VALUES (%s, %s, %s)
        RETURNING doctor_id
        """,
        (
            employee_id,
            random.choice(specialization_ids),
            species_id,
        ),
    )

    doctor_id = cur.fetchone()[0]
    doctor_ids.append(doctor_id)
    doctor_species_map[doctor_id] = species_id

# ------------------------
# Observation
# ------------------------

for pet_id in random.sample(pet_ids, min(OBS_PETS_LIMIT, len(pet_ids))):
    for indicator_id in indicator_ids:
        base_value = random.uniform(10, 50)

        for _ in range(OBS_PER_INDICATOR):
            value = round(base_value + random.uniform(-5, 5), 2)

            cur.execute(
                """
                INSERT INTO Observation (pet_id, indicator_id, value)
                VALUES (%s, %s, %s)
                """,
                (pet_id, indicator_id, value),
            )

# ------------------------
# Visits
# ------------------------

for _ in range(NUM_VISITS):
    species_id = random.choice(species_ids)

    pets = [pet_id for pet_id, pet_species_id in pet_species_map.items() if pet_species_id == species_id]
    if not pets:
        continue

    doctors = [doctor_id for doctor_id, doctor_species_id in doctor_species_map.items() if doctor_species_id == species_id]
    if not doctors:
        continue

    pet_id = random.choice(pets)
    doctor_id = random.choice(doctors)
    visit_status = random.choices(VISIT_STATUSES, weights=VISIT_STATUS_WEIGHTS, k=1)[0]
    visit_date = build_visit_datetime(visit_status)

    cur.execute(
        """
        INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
        VALUES (%s, %s, %s, %s)
        RETURNING visit_id
        """,
        (doctor_id, pet_id, visit_date, visit_status),
    )

    visit_id = cur.fetchone()[0]

    if visit_status == "cancelled":
        continue

    selected_services = random.sample(
        service_ids,
        min(len(service_ids), random.randint(1, 4)),
    )

    total_amount = 0

    for service_id in selected_services:
        cur.execute(
            """
            INSERT INTO Visit_Service (visit_id, service_id)
            VALUES (%s, %s)
            """,
            (visit_id, service_id),
        )
        total_amount += service_prices[service_id]

    is_paid = visit_status == "completed" and random.choice([True, False])

    cur.execute(
        """
        INSERT INTO Bill (visit_id, amount, is_paid)
        VALUES (%s, %s, %s)
        """,
        (visit_id, total_amount, is_paid),
    )

    if visit_status == "completed" and random.random() < 0.65:
        prescription_text, medication = random.choice(PRESCRIPTIONS)

        cur.execute(
            """
            INSERT INTO Prescription (visit_id, prescription_text, medication)
            VALUES (%s, %s, %s)
            """,
            (visit_id, prescription_text, medication),
        )

# ------------------------

conn.commit()
cur.close()
conn.close()

print("Test data generated successfully.")
