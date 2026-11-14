-- Portfolio 3: concurrency and isolation, SESSION B
-- Run in the second Query Tool tab. Do not run this whole file at once.
-- B1: run only after Session A has made its withdrawal but has NOT committed.
SET
    application_name = 'session_p3_b';

BEGIN ISOLATION LEVEL READ COMMITTED;

SHOW transaction_isolation;

-- Expected: 28000.00. Session A's withdrawal is not committed, so it is invisible here.
SELECT
    balance
FROM
    account
WHERE
    account_number = '0100000003';

-- Start a withdrawal of 15,000 NGN from the same account.
INSERT INTO
    transaction (
        transaction_id,
        reference,
        type,
        amount,
        currency,
        status
    )
VALUES
    (
        '80000000-0000-0000-0000-000000000004',
        'TXN-0014',
        'WITHDRAWAL',
        15000.00,
        'NGN',
        'COMPLETED'
    );

INSERT INTO
    ledger_entry (transaction_id, account_id, amount, type)
VALUES
    (
        '80000000-0000-0000-0000-000000000004',
        (
            SELECT
                account_id
            FROM
                account
            WHERE
                account_number = '0100000003'
        ),
        15000.00,
        'DEBIT'
    );

UPDATE account
SET
    balance = balance - 15000.00
WHERE
    account_number = '0100000003';

-- WAIT here. This UPDATE does not finish. Switch to Session A for A2 and COMMIT.
-- B2: after the check-constraint error, clear the failed transaction.
ROLLBACK;

-- Exactly one withdrawal was recorded, and the balance reflects only that one.
SELECT
    balance
FROM
    account
WHERE
    account_number = '0100000003';

SELECT
    reference,
    amount,
    status
FROM
    transaction
WHERE
    reference IN ('TXN-0013', 'TXN-0014')
ORDER BY
    reference;