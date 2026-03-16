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

# Генерация визитов
for i in range(100):
    cur.execute(
        """INSERT INTO Visit (doctor_id, pet_id, visit_date, status)
           VALUES (%s,%s,%s,%s)""",
        (
            1,
            random.randint(1, 100),
            datetime.now() - timedelta(days=random.randint(1, 365)),
            random.choice(['scheduled','completed','cancelled'])
        )
    )

conn.commit()
cur.close()
conn.close()

print("Test data generated successfully.")