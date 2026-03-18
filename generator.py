import psycopg2
import random
from datetime import datetime, timedelta

conn = psycopg2.connect(
    dbname="vet_clinic",
    user="postgres",
    password="sql",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

# Генерация клиентов
for i in range(50):
    cur.execute(
        "INSERT INTO Client (passport, full_name, gender) VALUES (%s,%s,%s)",
        (f"PP{i:07d}", f"Client {i}", random.choice(['M','F']))
    )

# Генерация питомцев
for i in range(100):
    cur.execute(
        """INSERT INTO Pet (client_id, species_id, nickname, age, weight)
           VALUES (%s,%s,%s,%s,%s)""",
        (
            random.randint(1, 50),
            random.randint(1, 4),
            f"Pet_{i}",
            random.randint(1, 15),
            round(random.uniform(1.0, 40.0), 2)
        )
    )

services = [
    ('General checkup', 1500),
    ('Vaccination', 1000),
    ('X-ray', 2500),
    ('Blood test', 1200),
    ('Ultrasound', 2000),
    ('Surgery', 8000)
]

for name, price in services:
    cur.execute(
        "INSERT INTO Service (service_name, price) VALUES (%s, %s)",
        (name, price)
    )

# Генерация визитов
for i in range(250):
    cur.execute(
        """INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
           VALUES (%s,%s,%s,%s)
           RETURNING visit_id""",
        (
            1,
            random.randint(1, 100),
            datetime.now() - timedelta(days=random.randint(1, 365)),
            random.choice(['scheduled','completed','cancelled'])
        )
    )

    visit_id = cur.fetchone()[0]

    # случайное количество услуг
    num_services = random.randint(1, 4)

    selected_services = random.sample(range(1, len(services) + 1), num_services)

    total_amount = 0

    for service_id in selected_services:
        # добавить услугу к визиту
        cur.execute(
            """INSERT INTO Visit_Service (visit_id, service_id)
               VALUES (%s, %s)""",
            (visit_id, service_id)
        )

        # получить цену услуги
        cur.execute(
            "SELECT price FROM Service WHERE service_id = %s",
            (service_id,)
        )
        price = cur.fetchone()[0]
        total_amount += price

    # создать счет
    cur.execute(
        """INSERT INTO Bill (visit_id, amount, is_paid)
           VALUES (%s, %s, %s)""",
        (
            visit_id,
            total_amount,
            random.choice([True, False])
        )
    )



conn.commit()
cur.close()
conn.close()

print("Test data generated successfully.")