-- Portfolio 3, Part 2: a transfer that fails and is rolled back
-- Tries to move 50,000 NGN from account 0100000001, which holds only 34,000.

-- Step 1: balances before
SELECT account_number, balance FROM account
WHERE account_number IN ('0100000001', '0100000003')
ORDER BY account_number;

-- Step 2: start the transaction and do everything except the debit
BEGIN;

INSERT INTO transaction (transaction_id, reference, type, amount, currency, status)
VALUES ('80000000-0000-0000-0000-000000000002', 'TXN-0012', 'TRANSFER', 50000.00, 'NGN', 'COMPLETED');

INSERT INTO ledger_entry (transaction_id, account_id, amount, type)
VALUES ('80000000-0000-0000-0000-000000000002',
        (SELECT account_id FROM account WHERE account_number = '0100000001'), 50000.00, 'DEBIT'),
       ('80000000-0000-0000-0000-000000000002',
        (SELECT account_id FROM account WHERE account_number = '0100000003'), 50000.00, 'CREDIT');

UPDATE account SET balance = balance + 50000.00 WHERE account_number = '0100000003';

-- Step 3: balances in the middle of the transaction
SELECT account_number, balance FROM account
WHERE account_number IN ('0100000001', '0100000003')
ORDER BY account_number;

-- Step 4: the debit. This breaks BR6 (balance cannot be negative) and fails.
UPDATE account SET balance = balance - 50000.00 WHERE account_number = '0100000001';

-- Step 5: cancel the whole transaction
ROLLBACK;

-- Step 6: balances after, and proof nothing was left behind
SELECT account_number, balance FROM account
WHERE account_number IN ('0100000001', '0100000003')
ORDER BY account_number;

SELECT count(*) AS txn_0012_rows FROM transaction WHERE reference = 'TXN-0012';