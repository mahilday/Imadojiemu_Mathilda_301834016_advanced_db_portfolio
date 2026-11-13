# Portfolio 1 Database Design and Modelling: CASE STUDY

## Star Bank case study

Star Bank is a simulated digital microfinance bank operating across Kenya and Nigeria. They typically provide services to small business owners by offering transfer and saving capabilities, accurate account statements with analysis, and bill payment options through a dedicated mobile application

### Users of the database

Users of the database include,

1. **Members** (End users): They use the mobile app to view their records and perform transactions.
2. **Developers** (application programmers): build and maintain the mobile
  application and backend services that read from and write to the database on
  behalf of members.
3. **Auditors**: Read only access to logs, accounts and transactions for compliance staff
4. **System administrators** (administrators): manage the database
  itself. They create staff user accounts and assign roles, monitor
  performance, and manage backups and recovery. 

### Major data stored

#### Authentication Data

1. Users (Staff)
2. Roles and permissions

#### General Data

1. Members (Bank customers)
2. Transactions
3. Billers
4. Member accounts
5. Logs for auditing records
6. Ledger entries 

### Key operations

1. Member authentication
2. User authentication (Role Based)
3. Deposit
4. Transfer
5. Withdrawal
6. Auditing balances
7. Reversing failed transactions
8. Bill payments

### Business rules

| ID   | Rule  |
| ---- | ----  |
| BR1  | Every member is identified by a unique member ID and has a unique email address and phone number.                                                                          |
| BR2  | Every member is registered in exactly one country, either Nigeria or Kenya. |
| BR3  | A member can hold zero or more accounts; each account belongs to exactly one member. |
| BR4  | Every account has a unique account number. |
| BR5  | Every account holds exactly one currency, NGN or KES, fixed when the account is opened. |
| BR6  | An account balance can never be negative. |
| BR7  | An account is ACTIVE, FROZEN or CLOSED, only active accounts can send or receive money.                                                                                    |
| BR8  | Every transaction is one of four types: deposit, withdrawal, transfer or bill payment. |
| BR9  | Every transaction amount must be greater than 0. |
| BR10 | A transfer debits one account and credits a different account by the same amount, and both accounts must hold the same currency.
| BR11 | Every transaction has a status: pending, completed, failed or reversed. |
| BR12 | A completed transaction is never edited or deleted. A reversal is recorded as a new transaction that references the original, and a transaction can be reversed only once. |
| BR13 | A bill payment must reference a registered biller. |
| BR14 | Every staff user has a unique email address and exactly one role but a role can be held by many users. |
| BR15 | A role can have many permissions, and a permission can belong to many roles.  |
| BR16 | Every create, update, delete or reversal action is written to an audit log, and audit log records are never changed or deleted. |
