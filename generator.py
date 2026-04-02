import psycopg2
import random
from datetime import datetime, timedelta

# ------------------------
# НАСТРОЙКИ (меняешь тут)
# ------------------------

NUM_CLIENTS = 50
NUM_PETS = 250
NUM_EMPLOYEES = 20
MIN_DOCTORS = 10
NUM_VISITS = 250
OBS_PETS_LIMIT = 100
OBS_PER_INDICATOR = 10

# ------------------------

conn = psycopg2.connect(
    dbname="vet_clinic",
    user="postgres",
    password="sql",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

# ------------------------
# Получаем реальные ID
# ------------------------

cur.execute("SELECT species_id FROM Species")
species_ids = [row[0] for row in cur.fetchall()]

cur.execute("SELECT indicator_id FROM Indicator")
indicator_ids = [row[0] for row in cur.fetchall()]

cur.execute("SELECT service_id FROM Service")
service_ids = [row[0] for row in cur.fetchall()]

cur.execute("SELECT specialization_id FROM Specialization")
specialization_ids = [row[0] for row in cur.fetchall()]

# ------------------------
# Клиенты
# ------------------------

for i in range(NUM_CLIENTS):
    cur.execute(
        "INSERT INTO Client (passport, full_name, gender) VALUES (%s,%s,%s)",
        (f"PP{i:07d}", f"Client {i}", random.choice(['M','F']))
    )

# получаем client_id
cur.execute("SELECT client_id FROM Client")
client_ids = [row[0] for row in cur.fetchall()]

# ------------------------
# Питомцы
# ------------------------

for i in range(NUM_PETS):
    cur.execute(
        """INSERT INTO Pet (client_id, species_id, nickname, age, weight)
           VALUES (%s,%s,%s,%s,%s)""",
        (
            random.choice(client_ids),
            random.choice(species_ids),   # ✔ фикс
            f"Pet_{i}",
            random.randint(1, 15),
            round(random.uniform(1.0, 40.0), 2)
        )
    )

# получаем pet_id
cur.execute("SELECT pet_id FROM Pet")
pet_ids = [row[0] for row in cur.fetchall()]

# ------------------------
# Employees + Doctors
# ------------------------

doctor_employee_ids = []

roles = ['registrar', 'administrator', 'doctor']

for i in range(NUM_EMPLOYEES):
    role = random.choice(roles)

    cur.execute(
        """INSERT INTO Employee (full_name, passport, phone, role)
           VALUES (%s,%s,%s,%s)
           RETURNING employee_id""",
        (
            f"Employee {i}",
            f"EMP{i:07d}",
            f"+7999000{i:03d}",
            role
        )
    )

    emp_id = cur.fetchone()[0]

    if role == 'doctor':
        doctor_employee_ids.append(emp_id)

# минимум врачей
while len(doctor_employee_ids) < MIN_DOCTORS:
    cur.execute(
        """INSERT INTO Employee (full_name, passport, phone, role)
           VALUES (%s,%s,%s,%s)
           RETURNING employee_id""",
        (
            f"Doctor extra {len(doctor_employee_ids)}",
            f"DOCX{len(doctor_employee_ids):05d}",
            f"+7999111{len(doctor_employee_ids):03d}",
            'doctor'
        )
    )

    doctor_employee_ids.append(cur.fetchone()[0])

doctor_ids = []

for emp_id in doctor_employee_ids:
    cur.execute(
        """INSERT INTO Doctor (employee_id, specialization_id, species_id)
           VALUES (%s,%s,%s)
           RETURNING doctor_id""",
        (
            emp_id,
            random.choice(specialization_ids),
            random.choice(species_ids)
        )
    )
    doctor_ids.append(cur.fetchone()[0])

# ------------------------
# Observation
# ------------------------

for pet_id in random.sample(pet_ids, min(OBS_PETS_LIMIT, len(pet_ids))):

    for indicator_id in indicator_ids:

        base_value = random.uniform(10, 50)

        for _ in range(OBS_PER_INDICATOR):

            value = round(base_value + random.uniform(-5, 5), 2)

            cur.execute(
                """INSERT INTO Observation (pet_id, indicator_id, value)
                   VALUES (%s,%s,%s)""",   # ✔ убрали observation_date
                (
                    pet_id,
                    indicator_id,
                    value
                )
            )

# ------------------------
# Visits
# ------------------------

for _ in range(NUM_VISITS):
    cur.execute(
        """INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
           VALUES (%s,%s,%s,%s)
           RETURNING visit_id""",
        (
            random.choice(doctor_ids),
            random.choice(pet_ids),  # ✔ фикс
            datetime.now() - timedelta(days=random.randint(1, 365)),
            random.choice(['scheduled','completed','cancelled'])
        )
    )

    visit_id = cur.fetchone()[0]

    selected_services = random.sample(service_ids, random.randint(1, 4))

    total_amount = 0

    for service_id in selected_services:
        cur.execute(
            """INSERT INTO Visit_Service (visit_id, service_id)
               VALUES (%s, %s)""",
            (visit_id, service_id)
        )

        cur.execute(
            "SELECT price FROM Service WHERE service_id = %s",
            (service_id,)
        )
        total_amount += cur.fetchone()[0]

    cur.execute(
        """INSERT INTO Bill (visit_id, amount, is_paid)
           VALUES (%s, %s, %s)""",
        (
            visit_id,
            total_amount,
            random.choice([True, False])
        )
    )

# ------------------------

conn.commit()
cur.close()
conn.close()

print("Test data generated successfully.")