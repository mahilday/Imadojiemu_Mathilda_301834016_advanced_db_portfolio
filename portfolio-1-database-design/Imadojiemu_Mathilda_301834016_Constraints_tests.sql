-- Star Bank constraint tests
-- Run after schema and sample-data run within this folder.
-- Every statement here breaks one business rule and should be REJECTED.

--N1: duplicate member email cannot exist
INSERT INTO
    member (full_name, email, phone, country, password)
VALUES
    (
        'Duplicate Person',
        'adaeze.okafor@mail.example',
        '+2348039999999',
        'NG',
        'placeholder'
    );

-- N2: country outside Nigeria and Kenya are rejected
INSERT INTO
    member (full_name, email, phone, country, password)
VALUES
    (
        'Kofi Mensah',
        'kofi.mensah@mail.example',
        '+233200000001',
        'GH',
        'placeholder'
    );

-- N3: account for a member that does not exist should be rejected
INSERT INTO
    account (member_id, account_number, currency)
VALUES
    (
        '99999999-9999-9999-9999-999999999999',
        '0100000099',
        'NGN'
    );

-- N4: deleting a member who still holds accounts is rejected
DELETE FROM member
WHERE
    member_id = '40000000-0000-0000-0000-000000000001';

-- N5: duplicate account number is not allowed
INSERT INTO
    account (member_id, account_number, currency)
VALUES
    (
        '40000000-0000-0000-0000-000000000002',
        '0100000001',
        'NGN'
    );

-- N6: currency other than NGN or KES - Rejected
INSERT INTO
    account (member_id, account_number, currency)
VALUES
    (
        '40000000-0000-0000-0000-000000000002',
        '0100000098',
        'USD'
    );

-- N7: negative balance - Rejected
UPDATE account
SET
    balance = -1
WHERE
    account_number = '0100000001';

-- N8: account status outside ACTIVE, FROZEN, CLOSED - Rejected
UPDATE account
SET
    status = 'SUSPENDED'
WHERE
    account_number = '0100000001';

-- N9: transaction type outside the four allowed - Rejected
INSERT INTO
    transaction (reference, type, amount, currency)
VALUES
    ('TXN-N009', 'LOAN', 1000, 'NGN');

-- N10: amount of zero
INSERT INTO
    transaction (reference, type, amount, currency)
VALUES
    ('TXN-N010', 'DEPOSIT', 0, 'NGN');

-- N11 BR10: the same account twice in one transaction
INSERT INTO
    ledger_entry (transaction_id, account_id, amount, type)
VALUES
    (
        '70000000-0000-0000-0000-000000000004',
        '50000000-0000-0000-0000-000000000001',
        10000,
        'CREDIT'
    );

-- N12 BR11: transaction status outside the four allowed
INSERT INTO
    transaction (reference, type, amount, currency, status)
VALUES
    ('TXN-N012', 'DEPOSIT', 1000, 'NGN', 'CANCELLED');

-- N13: reversing a transaction that was already reversed
INSERT INTO
    transaction (
        reference,
        type,
        amount,
        currency,
        reverse_transaction_id
    )
VALUES
    (
        'TXN-N013',
        'TRANSFER',
        2000,
        'NGN',
        '70000000-0000-0000-0000-000000000008'
    );

-- N14: a transaction reversing itself
INSERT INTO
    transaction (
        transaction_id,
        reference,
        type,
        amount,
        currency,
        reverse_transaction_id
    )
VALUES
    (
        '70000000-0000-0000-0000-000000000099',
        'TXN-N014',
        'DEPOSIT',
        1000,
        'NGN',
        '70000000-0000-0000-0000-000000000099'
    );

-- N15: bill payment with no biller
INSERT INTO
    transaction (reference, type, amount, currency)
VALUES
    ('TXN-N015', 'BILL_PAYMENT', 1000, 'NGN');

-- N16: deposit that names a biller - Rejected
INSERT INTO
    transaction (reference, type, amount, currency, biller_id)
VALUES
    (
        'TXN-N016',
        'DEPOSIT',
        1000,
        'NGN',
        '60000000-0000-0000-0000-000000000001'
    );

-- N17: staff user with no role - Rejected
INSERT INTO
    staff_user (role_id, full_name, email, password)
VALUES
    (
        NULL,
        'No Role',
        'no.role@starbank.example',
        'placeholder'
    );

-- N18: duplicate staff email - Rejected
INSERT INTO
    staff_user (role_id, full_name, email, password)
VALUES
    (
        '10000000-0000-0000-0000-000000000003',
        'Duplicate Staff',
        'ngozi.eze@starbank.example',
        'placeholder'
    );

-- N19: the same permission granted to the same role twice - Rejected
INSERT INTO
    role_permission (role_id, permission_id)
VALUES
    (
        '10000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000004'
    );

-- N20: An audit record with two action takers - Rejected
INSERT INTO
    audit_log (
        staff_user_id,
        member_id,
        action,
        table_name,
        record_id
    )
VALUES
    (
        '30000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        'UPDATE',
        'account',
        '50000000-0000-0000-0000-000000000001'
    );