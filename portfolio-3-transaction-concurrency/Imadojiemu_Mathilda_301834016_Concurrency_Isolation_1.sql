-- Portfolio 3: concurrency and isolation, SESSION A
-- Run in the first Query Tool tab. Do not run this whole file at once.
-- Follow the order: A1, then B1 (other tab), then A2, then B2 (other tab).

-- A1: start a withdrawal of 20,000 NGN from account 0100000003.
SET application_name = 'session_p3_a';
BEGIN ISOLATION LEVEL READ COMMITTED;
SHOW transaction_isolation;

INSERT INTO transaction (transaction_id, reference, type, amount, currency, status)
VALUES ('80000000-0000-0000-0000-000000000003', 'TXN-0013', 'WITHDRAWAL', 20000.00, 'NGN', 'COMPLETED');

INSERT INTO ledger_entry (transaction_id, account_id, amount, type)
VALUES ('80000000-0000-0000-0000-000000000003',
        (SELECT account_id FROM account WHERE account_number = '0100000003'), 20000.00, 'DEBIT');

UPDATE account SET balance = balance - 20000.00 WHERE account_number = '0100000003';

-- Session A now sees its own uncommitted change. Expected: 8000.00
SELECT balance FROM account WHERE account_number = '0100000003';
-- STOP. Leave this transaction open. Run B1 in the second tab now.

-- A2: after Session B's UPDATE is waiting, run this in Session A.
SELECT application_name, wait_event_type FROM pg_stat_activity
WHERE application_name = 'session_p3_b';
-- Expected: session_p3_b | Lock. Take the waiting screenshot, then continue.
COMMIT;
-- Switch to Session B: its UPDATE should now fail on account_balance_check.