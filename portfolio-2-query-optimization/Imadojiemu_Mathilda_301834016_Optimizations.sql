-- Star Bank query optimization test (Portfolio 2)
-- Run this setup once. The test rows are kept in a separate schema,
-- away from the Star bank DB. This is a performance-test table,
-- not a replacement for the transaction table.
CREATE SCHEMA performance_p2_test;

-- Generate 200,000 transactions, one every 5 minutes from 1 January 2024.
-- Every value is calculated from the row number g, so the data is the same
-- on every run. Types: 40% deposit, 20% withdrawal, 30% transfer, 10% bill payment.
CREATE TABLE performance_p2_test.transaction_history AS
SELECT gen_random_uuid() AS transaction_id,
       'HIS-' || lpad(g::text, 7, '0') AS reference,
       CASE WHEN g % 10 < 4 THEN 'DEPOSIT'
            WHEN g % 10 < 6 THEN 'WITHDRAWAL'
            WHEN g % 10 < 9 THEN 'TRANSFER'
            ELSE 'BILL_PAYMENT' END AS type,
       (100 + (g * 37) % 19900)::numeric(18, 2) AS amount,
       CASE WHEN (g / 7) % 2 = 0 THEN 'NGN' ELSE 'KES' END AS currency,
       CASE WHEN g % 50 = 0 THEN 'PENDING'
            WHEN g % 17 = 0 THEN 'FAILED'
            ELSE 'COMPLETED' END AS status,
       TIMESTAMPTZ '2024-01-01 00:00:00+00' + g * INTERVAL '5 minutes' AS created_at
FROM generate_series(1, 200000) AS g;

-- Refresh the planner's information about the test table.
ANALYZE performance_p2_test.transaction_history;

-- Check the data before comparing plans: 200000 rows, then 288 on the chosen day.
SELECT count(*) AS test_rows FROM performance_p2_test.transaction_history;
SELECT count(*) AS transactions_on_day FROM performance_p2_test.transaction_history
WHERE created_at >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
  AND created_at <  TIMESTAMPTZ '2025-01-02 00:00:00+00';

-- The query under test: daily summary of completed transactions by type.
SELECT type, count(*) AS transactions, sum(amount) AS total_amount
FROM performance_p2_test.transaction_history
WHERE created_at >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
  AND created_at <  TIMESTAMPTZ '2025-01-02 00:00:00+00'
  AND status = 'COMPLETED'
GROUP BY type
ORDER BY type;

-- BEFORE: run this four times.
-- Ignore the first run; record the next three Execution Time values.
EXPLAIN (ANALYZE, BUFFERS)
SELECT type, count(*) AS transactions, sum(amount) AS total_amount
FROM performance_p2_test.transaction_history
WHERE created_at >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
  AND created_at <  TIMESTAMPTZ '2025-01-02 00:00:00+00'
  AND status = 'COMPLETED'
GROUP BY type
ORDER BY type;

-- Add only this index. The rows and the query stay the same.
CREATE INDEX transaction_history_created_at_idx
    ON performance_p2_test.transaction_history (created_at);

-- AFTER: run the identical query four times.
-- Again ignore the first run and record three Execution Time values.
EXPLAIN (ANALYZE, BUFFERS)
SELECT type, count(*) AS transactions, sum(amount) AS total_amount
FROM performance_p2_test.transaction_history
WHERE created_at >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
  AND created_at <  TIMESTAMPTZ '2025-01-02 00:00:00+00'
  AND status = 'COMPLETED'
GROUP BY type
ORDER BY type;