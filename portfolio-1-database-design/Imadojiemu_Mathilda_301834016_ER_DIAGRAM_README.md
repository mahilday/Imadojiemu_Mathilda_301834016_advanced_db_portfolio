# ER DIAGRAM - STAR BANK

## Important Diagram Interpretation Satisfying Business Rules

- **PK** identifies one record. **FK** links to another table. **UK** means a value is unique.
- `||` means exactly one. `o|` means zero or one. `o{` means zero or many. `|{` means one or many.
- A member can hold zero or many accounts. Each account belongs to one member. (BR3)
- A transaction is recorded as one or many ledger entries. Each entry belongs to one transaction and affects one account. (BR10)
- An account can be affected by zero or many ledger entries over time.
- A biller can be paid in zero or many transactions. A transaction refers to a biller only when it is a BILL_PAYMENT. (BR13)
- A transaction can reverse at most one earlier transaction, and a transaction can be reversed at most once. (BR12)
- Each staff user has exactly one role. A role can be assigned to zero or many staff users. (BR14)
- Roles and permissions are many-to-many, linked through role_permission. (BR15)
- Every audit log record is linked to the staff user or member who performed the action, or to neither when the system acted. (BR16)


The diagram below shows the relationships within all entities in this case study

```mermaid
erDiagram
    member ||--o{ account : holds
    transaction ||--o{ ledger_entry : "is recorded as"
    account ||--o{ ledger_entry : "is affected by"
    biller |o--o{ transaction : "is paid in"
    transaction |o--o| transaction : reverses
    role ||--o{ staff_user : "is assigned to"
    role ||--o{ role_permission : grants
    permission ||--o{ role_permission : "is granted in"
    staff_user |o--o{ audit_log : performs
    member |o--o{ audit_log : performs

    member {
        uuid member_id PK
        varchar(120) full_name
        varchar(254) email UK
        varchar(20) phone UK
        char(2) country "NG or KE"
        varchar(255) password "Password hash"
        timestamptz created_at
        timestamptz updated_at
    }
    account {
        uuid account_id PK
        uuid member_id FK
        char(10) account_number UK
        char(3) currency "NGN or KES"
        numeric balance "Never negative"
        varchar(10) status "ACTIVE, FROZEN or CLOSED"
        timestamptz created_at
    }
    transaction {
        uuid transaction_id PK
        varchar(30) reference UK
        varchar(15) type "DEPOSIT, WITHDRAWAL, TRANSFER or BILL_PAYMENT"
        numeric amount "Greater than zero"
        char(3) currency "NGN or KES"
        varchar(15) status "PENDING, COMPLETED, FAILED or REVERSED"
        uuid biller_id FK "Only for bill payments"
        uuid reverse_transaction_id FK, UK "Only for reversals"
        timestamptz created_at
    }
    ledger_entry {
        uuid entry_id PK
        uuid transaction_id FK
        uuid account_id FK
        numeric amount "Never negative"
        varchar(6) type "DEBIT or CREDIT"
    }
    biller {
        uuid biller_id PK
        varchar(120) name UK
        varchar(50) category
        char(2) country "NG or KE"
    }
    staff_user {
        uuid user_id PK
        uuid role_id FK
        varchar(120) full_name
        varchar(254) email UK
        varchar(255) password "Password hash"
        boolean is_active
    }
    role {
        uuid role_id PK
        varchar(50) name UK
    }
    permission {
        uuid permission_id PK
        varchar(60) code UK
        varchar(200) description
    }
    role_permission {
        uuid role_id PK, FK
        uuid permission_id PK, FK
    }
    audit_log {
        uuid log_id PK
        uuid staff_user_id FK "Empty for member or system actions"
        uuid member_id FK "Empty for staff or system actions"
        varchar(50) action "CREATE, UPDATE, DELETE, REVERSE"
        varchar(50) table_name
        uuid record_id
        timestamptz created_at
    }
```

**Examples: An important take-away**

*Scenario*

1. *Member transferring from account A to account B:*

This would require one transaction and two ledger entries (one for CREDIT on B and another for DEBIT on A), both amounts need to be the exact same which shows transparency, consistency and balance keeping.

2. *Member depositing into account A*:

This requires one transaction and 1 ledger entry (CREDIT to account A).



