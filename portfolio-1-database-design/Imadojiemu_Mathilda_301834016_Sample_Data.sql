-- Star Bank sample data
-- Run once, after schema.sql, against the star_bank database.
-- Every statement here is valid and should succeed.

BEGIN;

-- Roles and permissions
INSERT INTO
    role (role_id, name)
VALUES
    ('10000000-0000-0000-0000-000000000001', 'ADMIN'),
    ('10000000-0000-0000-0000-000000000002', 'AUDITOR'),
    ('10000000-0000-0000-0000-000000000003', 'SUPPORT');

INSERT INTO
    permission (permission_id, code, description)
VALUES
    (
        '20000000-0000-0000-0000-000000000001',
        'STAFF_MANAGE',
        'Create staff users and assign roles'
    ),
    (
        '20000000-0000-0000-0000-000000000002',
        'ACCOUNT_FREEZE',
        'Freeze or unfreeze a member account'
    ),
    (
        '20000000-0000-0000-0000-000000000003',
        'TRANSACTION_REVERSE',
        'Reverse a completed transaction'
    ),
    (
        '20000000-0000-0000-0000-000000000004',
        'AUDIT_LOG_VIEW',
        'Read the audit log'
    );

INSERT INTO
    role_permission (role_id, permission_id)
VALUES
    (
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001'
    ),
    (
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000002'
    ),
    (
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000004'
    ),
    (
        '10000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000004'
    ),
    (
        '10000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000002'
    ),
    (
        '10000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000003'
    );

-- Staff users (passwords are placeholder hashes, not real credentials)
INSERT INTO
    staff_user (user_id, role_id, full_name, email, password)
VALUES
    (
        '30000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        'Ngozi Eze',
        'ngozi.eze@starbank.example',
        'placeholder-hash-1'
    ),
    (
        '30000000-0000-0000-0000-000000000002',
        '10000000-0000-0000-0000-000000000002',
        'Brian Mwangi',
        'brian.mwangi@starbank.example',
        'placeholder-hash-2'
    ),
    (
        '30000000-0000-0000-0000-000000000003',
        '10000000-0000-0000-0000-000000000003',
        'Halima Yusuf',
        'halima.yusuf@starbank.example',
        'placeholder-hash-3'
    );

-- Members: two in Nigeria, two in Kenya for considerable distribution
INSERT INTO
    member (
        member_id,
        full_name,
        email,
        phone,
        country,
        password
    )
VALUES
    (
        '40000000-0000-0000-0000-000000000001',
        'Adaeze Okafor',
        'adaeze.okafor@mail.example',
        '+2348030000001',
        'NG',
        'placeholder-hash-4'
    ),
    (
        '40000000-0000-0000-0000-000000000002',
        'Tunde Bakare',
        'tunde.bakare@mail.example',
        '+2348030000002',
        'NG',
        'placeholder-hash-5'
    ),
    (
        '40000000-0000-0000-0000-000000000003',
        'Wanjiru Kamau',
        'wanjiru.kamau@mail.example',
        '+254710000001',
        'KE',
        'placeholder-hash-6'
    ),
    (
        '40000000-0000-0000-0000-000000000004',
        'Otieno Odhiambo',
        'otieno.odhiambo@mail.example',
        '+254710000002',
        'KE',
        'placeholder-hash-7'
    );

-- Accounts (BR3, BR4, BR5). Adaeze holds two accounts.
-- Balances equal the sum of each account's ledger entries below.
INSERT INTO
    account (
        account_id,
        member_id,
        account_number,
        currency,
        balance
    )
VALUES
    (
        '50000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '0100000001',
        'NGN',
        35000.00
    ),
    (
        '50000000-0000-0000-0000-000000000002',
        '40000000-0000-0000-0000-000000000001',
        '0100000002',
        'NGN',
        0.00
    ),
    (
        '50000000-0000-0000-0000-000000000003',
        '40000000-0000-0000-0000-000000000002',
        '0100000003',
        'NGN',
        27000.00
    ),
    (
        '50000000-0000-0000-0000-000000000004',
        '40000000-0000-0000-0000-000000000003',
        '0200000001',
        'KES',
        11000.00
    ),
    (
        '50000000-0000-0000-0000-000000000005',
        '40000000-0000-0000-0000-000000000004',
        '0200000002',
        'KES',
        4000.00
    );

-- Billers (BR13)
INSERT INTO
    biller (biller_id, name, category, country)
VALUES
    (
        '60000000-0000-0000-0000-000000000001',
        'Lagos Power Distribution',
        'Electricity',
        'NG'
    ),
    (
        '60000000-0000-0000-0000-000000000002',
        'NaijaTel Airtime',
        'Airtime',
        'NG'
    ),
    (
        '60000000-0000-0000-0000-000000000003',
        'Nairobi Water Services',
        'Water',
        'KE'
    ),
    (
        '60000000-0000-0000-0000-000000000004',
        'SafariLink Airtime',
        'Airtime',
        'KE'
    );

-- Transactions (BR8 to BR13)
INSERT INTO
    transaction (
        transaction_id,
        reference,
        type,
        amount,
        currency,
        status,
        biller_id,
        reverse_transaction_id
    )
VALUES
    (
        '70000000-0000-0000-0000-000000000001',
        'TXN-0001',
        'DEPOSIT',
        50000.00,
        'NGN',
        'COMPLETED',
        NULL,
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000002',
        'TXN-0002',
        'DEPOSIT',
        20000.00,
        'NGN',
        'COMPLETED',
        NULL,
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000003',
        'TXN-0003',
        'DEPOSIT',
        15000.00,
        'KES',
        'COMPLETED',
        NULL,
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000004',
        'TXN-0004',
        'TRANSFER',
        10000.00,
        'NGN',
        'COMPLETED',
        NULL,
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000005',
        'TXN-0005',
        'BILL_PAYMENT',
        5000.00,
        'NGN',
        'COMPLETED',
        '60000000-0000-0000-0000-000000000001',
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000006',
        'TXN-0006',
        'WITHDRAWAL',
        3000.00,
        'NGN',
        'COMPLETED',
        NULL,
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000007',
        'TXN-0007',
        'TRANSFER',
        4000.00,
        'KES',
        'COMPLETED',
        NULL,
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000008',
        'TXN-0008',
        'TRANSFER',
        2000.00,
        'NGN',
        'REVERSED',
        NULL,
        NULL
    ),
    (
        '70000000-0000-0000-0000-000000000009',
        'TXN-0009',
        'TRANSFER',
        2000.00,
        'NGN',
        'COMPLETED',
        NULL,
        '70000000-0000-0000-0000-000000000008'
    ),
    (
        '70000000-0000-0000-0000-000000000010',
        'TXN-0010',
        'WITHDRAWAL',
        90000.00,
        'NGN',
        'FAILED',
        NULL,
        NULL
    );

-- Ledger entries (BR10). A transfer has two entries; other types have one.
-- TXN-0010 failed before any money moved, so it has no entries.
INSERT INTO
    ledger_entry (transaction_id, account_id, amount, type)
VALUES
    (
        '70000000-0000-0000-0000-000000000001',
        '50000000-0000-0000-0000-000000000001',
        50000.00,
        'CREDIT'
    ),
    (
        '70000000-0000-0000-0000-000000000002',
        '50000000-0000-0000-0000-000000000003',
        20000.00,
        'CREDIT'
    ),
    (
        '70000000-0000-0000-0000-000000000003',
        '50000000-0000-0000-0000-000000000004',
        15000.00,
        'CREDIT'
    ),
    (
        '70000000-0000-0000-0000-000000000004',
        '50000000-0000-0000-0000-000000000001',
        10000.00,
        'DEBIT'
    ),
    (
        '70000000-0000-0000-0000-000000000004',
        '50000000-0000-0000-0000-000000000003',
        10000.00,
        'CREDIT'
    ),
    (
        '70000000-0000-0000-0000-000000000005',
        '50000000-0000-0000-0000-000000000001',
        5000.00,
        'DEBIT'
    ),
    (
        '70000000-0000-0000-0000-000000000006',
        '50000000-0000-0000-0000-000000000003',
        3000.00,
        'DEBIT'
    ),
    (
        '70000000-0000-0000-0000-000000000007',
        '50000000-0000-0000-0000-000000000004',
        4000.00,
        'DEBIT'
    ),
    (
        '70000000-0000-0000-0000-000000000007',
        '50000000-0000-0000-0000-000000000005',
        4000.00,
        'CREDIT'
    ),
    (
        '70000000-0000-0000-0000-000000000008',
        '50000000-0000-0000-0000-000000000001',
        2000.00,
        'DEBIT'
    ),
    (
        '70000000-0000-0000-0000-000000000008',
        '50000000-0000-0000-0000-000000000002',
        2000.00,
        'CREDIT'
    ),
    (
        '70000000-0000-0000-0000-000000000009',
        '50000000-0000-0000-0000-000000000002',
        2000.00,
        'DEBIT'
    ),
    (
        '70000000-0000-0000-0000-000000000009',
        '50000000-0000-0000-0000-000000000001',
        2000.00,
        'CREDIT'
    );

-- Audit log (BR16): one member action, one staff action, one system action
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
        NULL,
        '40000000-0000-0000-0000-000000000001',
        'CREATE',
        'transaction',
        '70000000-0000-0000-0000-000000000004'
    ),
    (
        '30000000-0000-0000-0000-000000000003',
        NULL,
        'REVERSE',
        'transaction',
        '70000000-0000-0000-0000-000000000008'
    ),
    (
        NULL,
        NULL,
        'UPDATE',
        'transaction',
        '70000000-0000-0000-0000-000000000010'
    );

COMMIT;