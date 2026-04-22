DROP INDEX IF EXISTS idx_visit_doctor_date;
DROP INDEX IF EXISTS idx_visit_completed_date_doctor;
DROP INDEX IF EXISTS idx_bill_visit_paid_amount;
DROP INDEX IF EXISTS idx_observation_pet_indicator_date_value;

-- CREATE INDEXES
CREATE INDEX idx_visit_doctor_date -- составной
ON Visit (doctor_id, visit_date);

CREATE INDEX idx_visit_completed_date_doctor -- частичный
ON Visit (visit_date, doctor_id)
WHERE status = 'completed';

CREATE INDEX idx_bill_visit_paid_amount -- покрывающий
ON Bill (visit_id)
INCLUDE (is_paid, amount);

CREATE INDEX idx_observation_pet_indicator_date_value -- составной + покрывающий
ON Observation (pet_id, indicator_id, observation_date DESC)
INCLUDE (value);

ANALYZE Visit;
ANALYZE Bill;
ANALYZE Observation;


-- Example 1
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    e.full_name,
    s.specialization_name,
    date_trunc('month', v.visit_date) AS month_start,
    COUNT(DISTINCT v.visit_id) AS visits_count,
    COALESCE(SUM(srv.price), 0) AS services_total,
    COUNT(*) FILTER (WHERE b.is_paid) AS paid_visits
FROM Visit v
JOIN Doctor d ON d.doctor_id = v.doctor_id
JOIN Employee e ON e.employee_id = d.employee_id
JOIN Specialization s ON s.specialization_id = d.specialization_id
LEFT JOIN Visit_Service vs ON vs.visit_id = v.visit_id
LEFT JOIN Service srv ON srv.service_id = vs.service_id
LEFT JOIN Bill b ON b.visit_id = v.visit_id
WHERE v.status = 'completed'
  AND v.visit_date >= DATE '2025-09-01'
  AND v.visit_date < DATE '2026-02-01'
  AND s.specialization_name = 'Surgery'
GROUP BY e.full_name, s.specialization_name, date_trunc('month', v.visit_date)
ORDER BY month_start, e.full_name;



-- Example 2
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    p.nickname,
    i.indicator_name,
    o.value,
    o.observation_date
FROM (
    SELECT DISTINCT ON (pet_id, indicator_id)
        pet_id,
        indicator_id,
        value,
        observation_date
    FROM Observation
    WHERE pet_id <= 100
    ORDER BY pet_id, indicator_id, observation_date DESC
) o
JOIN Pet p ON p.pet_id = o.pet_id
JOIN Indicator i ON i.indicator_id = o.indicator_id
ORDER BY p.nickname, i.indicator_name;