-- Portfolio 3, Part 1: a transfer that commits
-- Moves 1,000 NGN from account 0100000001 to account 0100000003.

-- Balances before
SELECT account_number, balance FROM account
WHERE account_number IN ('0100000001', '0100000003')
ORDER BY account_number;

BEGIN;

-- 1. Record the transfer itself
INSERT INTO transaction (transaction_id, reference, type, amount, currency, status)
VALUES ('80000000-0000-0000-0000-000000000001', 'TXN-0011', 'TRANSFER', 1000.00, 'NGN', 'COMPLETED');

-- 2. Record both sides in the ledger
INSERT INTO ledger_entry (transaction_id, account_id, amount, type)
VALUES ('80000000-0000-0000-0000-000000000001',
        (SELECT account_id FROM account WHERE account_number = '0100000001'), 1000.00, 'DEBIT'),
       ('80000000-0000-0000-0000-000000000001',
        (SELECT account_id FROM account WHERE account_number = '0100000003'), 1000.00, 'CREDIT');

-- 3. Move the money
UPDATE account SET balance = balance - 1000.00 WHERE account_number = '0100000001';
UPDATE account SET balance = balance + 1000.00 WHERE account_number = '0100000003';

COMMIT;

-- Balances after
SELECT account_number, balance FROM account
WHERE account_number IN ('0100000001', '0100000003')
ORDER BY account_number;