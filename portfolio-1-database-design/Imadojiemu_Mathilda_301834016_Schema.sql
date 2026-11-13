-- Star bank database system
-- SQL database setup; Run in Query Tool against the star_bank database
BEGIN;

--1. member: member profile
CREATE TABLE
    member (
        member_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        full_name VARCHAR(120) NOT NULL,
        email VARCHAR(254) NOT NULL UNIQUE,
        phone VARCHAR(20) NOT NULL UNIQUE,
        country CHAR(2) NOT NULL CHECK (country IN ('NG', 'KE')),
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now (),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT now ()
    );

--2. account: member account which is identified by the account number
CREATE TABLE
    account (
        account_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        member_id UUID NOT NULL REFERENCES member (member_id) ON DELETE RESTRICT,
        account_number CHAR(10) NOT NULL UNIQUE,
        currency CHAR(3) NOT NULL CHECK (currency IN ('NGN', 'KES')),
        balance NUMERIC(18, 2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
        status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
        created_at TIMESTAMPTZ NOT NULL DEFAULT now ()
    );

--3. biller: companies that members pay bills to
CREATE TABLE
    biller (
        biller_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        name VARCHAR(120) NOT NULL UNIQUE,
        category VARCHAR(50) NOT NULL,
        country CHAR(2) NOT NULL CHECK (country IN ('NG', 'KE'))
    );

--4. transaction: everything that requires moving any amount
CREATE TABLE
    transaction (
        transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        reference VARCHAR(30) NOT NULL UNIQUE,
        type VARCHAR(15) NOT NULL CHECK (
            type IN (
                'DEPOSIT',
                'WITHDRAWAL',
                'TRANSFER',
                'BILL_PAYMENT'
            )
        ),
        amount NUMERIC(18, 2) NOT NULL CHECK (amount > 0),
        currency CHAR(3) NOT NULL CHECK (currency IN ('NGN', 'KES')),
        status VARCHAR(15) DEFAULT 'PENDING' NOT NULL CHECK (
            status IN ('PENDING', 'COMPLETED', 'FAILED', 'REVERSED')
        ),
        biller_id UUID REFERENCES biller (biller_id) ON DELETE RESTRICT,
        reverse_transaction_id UUID UNIQUE REFERENCES transaction (transaction_id) ON DELETE RESTRICT,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now (),
        CONSTRAINT biller_only_on_bill_payment CHECK ((type = 'BILL_PAYMENT') = (biller_id IS NOT NULL)),
        CONSTRAINT no_self_reversal CHECK (reverse_transaction_id <> transaction_id)
    );

--5. role: staff job roles
CREATE TABLE
    role (
        role_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        name VARCHAR(50) NOT NULL UNIQUE
    );

--6. permission: individual actions a role may be allowed
CREATE TABLE
    permission (
        permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        code VARCHAR(60) NOT NULL UNIQUE,
        description VARCHAR(200) NOT NULL
    );

--7. staff_user: bank staff who log in to internal dashboards
CREATE TABLE
    staff_user (
        user_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        role_id UUID NOT NULL REFERENCES role (role_id) ON DELETE RESTRICT, -- BR14
        full_name VARCHAR(120) NOT NULL,
        email VARCHAR(254) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        is_active BOOLEAN NOT NULL DEFAULT TRUE
    );

--8. role_permission: links roles to permissions (many-to-many)
CREATE TABLE
    role_permission (
        role_id UUID NOT NULL REFERENCES role (role_id) ON DELETE CASCADE,
        permission_id UUID NOT NULL REFERENCES permission (permission_id) ON DELETE CASCADE,
        PRIMARY KEY (role_id, permission_id)
    );

--9. ledger_entry: one row per account carrying a transaction
CREATE TABLE
    ledger_entry (
        entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        transaction_id UUID NOT NULL REFERENCES transaction (transaction_id) ON DELETE RESTRICT,
        account_id UUID NOT NULL REFERENCES account (account_id) ON DELETE RESTRICT,
        amount NUMERIC(18, 2) NOT NULL CHECK (amount > 0),
        type VARCHAR(6) NOT NULL CHECK (type IN ('DEBIT', 'CREDIT')),
        UNIQUE (transaction_id, account_id)
    );

--10. audit_log: record user operations within the system
CREATE TABLE
    audit_log (
        log_id UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        staff_user_id UUID REFERENCES staff_user (user_id) ON DELETE RESTRICT,
        member_id UUID REFERENCES member (member_id) ON DELETE RESTRICT,
        action VARCHAR(50) NOT NULL CHECK (
            action IN ('CREATE', 'UPDATE', 'DELETE', 'REVERSE')
        ),
        table_name VARCHAR(50) NOT NULL,
        record_id UUID NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now (),
        CHECK (
            staff_user_id IS NULL
            OR member_id IS NULL
        )
    );

COMMIT;