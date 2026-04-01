-- 1 Получить отчет о приемах каждого врача на прошлой неделе
WITH visit_data AS (
    SELECT
        v.visit_id,
        e.full_name AS doctor_name,
        c.full_name AS client_name,
        p.nickname AS pet_name,
        s2.species_name,
        v.visit_date,
        s.service_name,
        s.price
    FROM Visit v
    JOIN Doctor d ON v.doctor_id = d.doctor_id
    JOIN Employee e ON d.employee_id = e.employee_id
    JOIN Pet p ON v.pet_id = p.pet_id
    JOIN Client c ON p.client_id = c.client_id
    JOIN Species s2 ON p.species_id = s2.species_id
    JOIN Visit_Service vs ON v.visit_id = vs.visit_id
    JOIN Service s ON vs.service_id = s.service_id
    WHERE v.visit_date >= date_trunc('week', CURRENT_DATE) - interval '1 week'
        AND v.visit_date < date_trunc('week', CURRENT_DATE)
)
SELECT
    visit_id AS "ID приема",
    doctor_name AS "Имя врача",
    client_name AS "Имя клиента",
    pet_name AS "Имя животного",
    species_name AS "Вид животного",
    visit_date AS "Дата приема",
    SUM(price) AS "Общая сумма",
    STRING_AGG(service_name, ', ') AS "Услуги"
FROM visit_data
GROUP BY visit_id, doctor_name, client_name, pet_name, species_name, visit_date
ORDER BY doctor_name, visit_date;
 

-- 2 Получить статистику о приемах разных видов животных в разрезе по месяцам за прошлый год
WITH base AS (
    SELECT
        s.species_name,
        EXTRACT(MONTH FROM v.visit_date) AS month,
        v.visit_id,
        p.pet_id,
        p.nickname,
        c.client_id,
        COALESCE(b.amount, 0) AS amount
    FROM Visit v
    JOIN Pet p ON v.pet_id = p.pet_id
    JOIN Client c ON p.client_id = c.client_id
    JOIN Species s ON p.species_id = s.species_id
    LEFT JOIN Bill b ON v.visit_id = b.visit_id
    WHERE EXTRACT(YEAR FROM v.visit_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
),
pet_freq AS (
    SELECT
        species_name,
        month,
        nickname,
        COUNT(*) AS cnt
    FROM base
    GROUP BY species_name, month, nickname
),
top_pet AS (
    SELECT
        species_name,
        month,
        nickname
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY species_name, month
                   ORDER BY cnt DESC
               ) AS rn
        FROM pet_freq
    )
    WHERE rn = 1
)
SELECT
    b.species_name AS "Вид животного",
    b.month AS "Месяц",
    COUNT(b.visit_id) AS "Количество приемов",
    SUM(b.amount) AS "Общая сумма",
    COUNT(DISTINCT b.pet_id) AS "Число уникальных животных",
    COUNT(DISTINCT b.client_id) AS "Число уникальных клиентов",
    tp.nickname AS "Самое популярное животное"
FROM base b
LEFT JOIN top_pet tp ON b.species_name = tp.species_name AND b.month = tp.month
GROUP BY b.species_name, b.month, tp.nickname
ORDER BY b.species_name, b.month;

-- 3 Получить отчет по популярности животных тех или иных видов за последние три года
WITH yearly AS (
    SELECT
        s.species_name,
        EXTRACT(YEAR FROM v.visit_date) AS year,
        COUNT(DISTINCT p.pet_id) AS pet_count
    FROM Visit v
    JOIN Pet p ON v.pet_id = p.pet_id
    JOIN Species s ON p.species_id = s.species_id
    WHERE v.visit_date >= CURRENT_DATE - INTERVAL '3 years'
    GROUP BY s.species_name, year
),
total AS (
    SELECT
        year,
        SUM(pet_count) AS total_pets
    FROM yearly
    GROUP BY year
)
SELECT
    y.species_name AS "Вид животного",
    y.year AS "Год",
    y.pet_count AS "Количество уникальных животных",
    ROUND(
        100::numeric * (y.pet_count - LAG(y.pet_count) OVER (PARTITION BY y.species_name ORDER BY y.year))
        / NULLIF(LAG(y.pet_count) OVER (PARTITION BY y.species_name ORDER BY y.year), 0),
        2
    ) AS "Изменение % к прошлому году",
    ROUND(100::numeric * y.pet_count / t.total_pets, 2)
        AS "Доля от общего %",
    ROUND(
        100::numeric * (
            (y.pet_count::numeric / t.total_pets) -
            LAG(y.pet_count::numeric / t.total_pets)
                OVER (PARTITION BY y.species_name ORDER BY y.year)
        ),
        2
    ) AS "Изменение доли %"
FROM yearly y
JOIN total t ON y.year = t.year
ORDER BY y.species_name, y.year;

-- 4 Вывести информацию по врачам, которые провели больше всех приемов за прошлый месяц. 
WITH visit_stats AS (
    SELECT
        e.employee_id,
        e.full_name AS doctor_name,
        sp.specialization_name,
        v.visit_id,
        v.visit_date,
        p.nickname AS pet_name,
        COUNT(vs.service_id) AS service_count,
        COALESCE(SUM(s.price), 0) AS visit_amount
    FROM Visit v
    JOIN Doctor d ON v.doctor_id = d.doctor_id
    JOIN Employee e ON d.employee_id = e.employee_id
    LEFT JOIN Specialization sp ON d.specialization_id = sp.specialization_id
    JOIN Pet p ON v.pet_id = p.pet_id
    LEFT JOIN Visit_Service vs ON v.visit_id = vs.visit_id
    LEFT JOIN Service s ON vs.service_id = s.service_id
    WHERE date_trunc('month', v.visit_date) =
          date_trunc('month', CURRENT_DATE) - interval '1 month'
    GROUP BY
        e.employee_id,
        e.full_name,
        sp.specialization_name,
        v.visit_id,
        v.visit_date,
        p.nickname
),
aggregated AS (
    SELECT
        employee_id,
        doctor_name,
        COUNT(*) AS visits_count,
        SUM(service_count) AS total_services,
        AVG(service_count) AS avg_services,
        MAX(visit_date) AS last_visit_date,
        SUM(visit_amount) AS total_amount,
        AVG(visit_amount) AS avg_amount,
        STRING_AGG(DISTINCT specialization_name, ', ') AS specializations
    FROM visit_stats
    GROUP BY employee_id, doctor_name
),
last_visit AS (
    SELECT
        vs.employee_id,
        vs.visit_date,
        vs.pet_name,
        vs.visit_amount,
        ROW_NUMBER() OVER (
            PARTITION BY vs.employee_id
            ORDER BY vs.visit_date DESC
        ) AS rn
    FROM visit_stats vs
)
SELECT
    a.doctor_name AS "Имя врача",
    a.visits_count AS "Число приемов",
    a.total_services AS "Число услуг",
    ROUND(a.avg_services::numeric, 2) AS "Среднее услуг на прием",
    a.specializations AS "Специализации",
    a.last_visit_date AS "Дата последнего приема",
    lv.pet_name AS "Животное последнего приема",
    lv.visit_amount AS "Сумма последнего приема",
    a.total_amount AS "Общая сумма",
    ROUND(a.avg_amount::numeric, 2) AS "Средняя сумма"
FROM aggregated a
JOIN last_visit lv ON a.employee_id = lv.employee_id AND lv.rn = 1
ORDER BY a.visits_count DESC;

-- 5 Вывести серию показателей для конкретного питомца, упорядоченную по дате
WITH obs AS (
    SELECT
        o.pet_id,
        o.observation_date,
        i.unit,
        o.value,

        LAG(o.value) OVER (
            PARTITION BY o.pet_id, o.indicator_id
            ORDER BY o.observation_date
        ) AS prev_value,

        AVG(o.value) OVER (
            PARTITION BY o.pet_id, o.indicator_id
        ) AS avg_value

    FROM Observation o
    JOIN Indicator i ON o.indicator_id = i.indicator_id
    WHERE o.pet_id = 1   -- нужный питомец
)

SELECT
    observation_date AS "Дата показания",
    unit AS "Единица измерения",
    value AS "Значение",

    (value - prev_value) AS "Разница с предыдущим",

    ROUND(
        ((value - prev_value) / NULLIF(prev_value, 0))::numeric * 100,
        2
    ) AS "Процентное изменение",

    ROUND(
        (value - avg_value)::numeric,
        2
    ) AS "Отклонение от среднего",

    CASE
        WHEN prev_value IS NULL THEN 'нет данных'
        WHEN value > prev_value THEN 'увеличивается'
        WHEN value < prev_value THEN 'уменьшается'
        ELSE 'без изменений'
    END AS "Признак изменения"

FROM obs
ORDER BY observation_date;
