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



## Evidence

| Required evidence | File | What it shows |
| --- | --- | --- |
| Case study description | [Star Bank case study](#star-bank-case-study) | Organisation, users of the database, major data stored, key operations |
| Business rules | [Business rules](#business-rules) | The 16 rules the design is built from |
| ER diagram | [ER_DIAGRAM_README.md](Imadojiemu_Mathilda_301834016_ER_DIAGRAM_README.md) | Ten entities, their attributes and relationships, with cardinality |
| Relational schema, keys and constraints | [Schema.sql](Imadojiemu_Mathilda_301834016_Schema.sql) | `CREATE TABLE` statements with primary keys, foreign keys, unique and check constraints |
| Normalisation explanation | [NORMALIZATION_README.md](Imadojiemu_Mathilda_301834016_NORMALIZATION_README.md) | The design taken from an unnormalised list through 1NF, 2NF and 3NF |
| Sample data | [Sample_Data.sql](Imadojiemu_Mathilda_301834016_Sample_Data.sql) | Valid rows for every table; all accepted |
| Constraint tests | [Constraints_tests.sql](Imadojiemu_Mathilda_301834016_Constraints_tests.sql) | 20 invalid statements covering the business rules; all rejected |

### Setup and data screenshots

| Screenshot | What it shows |
| --- | --- |
| [Database_Connection](screenshots/Imadojiemu_Mathilda_301834016_Database_Connection.png) | Connection to the `star_bank` database |
| [Table_Creation](screenshots/Imadojiemu_Mathilda_301834016_Table_Creation.png) | The schema script completing with `COMMIT` |
| [Table_List](screenshots/Imadojiemu_Mathilda_301834016_Table_List.png) | All ten tables listed in the database |
| [Sample_Data](screenshots/Imadojiemu_Mathilda_301834016_Sample_Data.png) | The sample data loading without errors |
| [Data_Confirmation](screenshots/Imadojiemu_Mathilda_301834016_Data_Confirmation.png) | Row counts confirming the data is in place |
| [ER_DIAGRAM](screenshots/Imadojiemu_Mathilda_301834016_ER_DIAGRAM.png) | The rendered ER diagram |

### Constraint test screenshots

| Screenshot | Rule | What was rejected |
| --- | --- | --- |
| [Duplicate_Member_Constraint](screenshots/Imadojiemu_Mathilda_301834016_Duplicate_Member_Constraint.png) | BR1 | A second member with an existing email |
| [Country_Checker_Constraint](screenshots/Imadojiemu_Mathilda_301834016_Country_Checker_Constraint.png) | BR2 | A member registered outside Nigeria and Kenya |
| [Non_Existent_Member_Constraint](screenshots/Imadojiemu_Mathilda_301834016_Non_Existent_Member_Constraint.png) | BR3 | An account for a member that does not exist |
| [Existing_Account_Constraint](screenshots/Imadojiemu_Mathilda_301834016_Existing_Account_Constraint.png) | BR3 | Deleting a member who still holds accounts |
| [Duplicate_Account_Number_Constraint](screenshots/Imadojiemu_Mathilda_301834016_Duplicate_Account_Number_Constraint.png) | BR4 | A second account with an existing account number |
| [Currency_Checker_Constraints](screenshots/Imadojiemu_Mathilda_301834016_Currency_Checker_Constraints.png) | BR5 | An account in a currency other than NGN or KES |
| [Transaction_Constraints](screenshots/Imadojiemu_Mathilda_301834016_Transaction_Constraints.png) | BR8 to BR12 | Invalid transaction types, amounts, statuses and reversals |
| [Biller_Constraint](screenshots/Imadojiemu_Mathilda_301834016_Biller_Constraint.png) | BR13 | A bill payment with no biller |
| [Staff_User_Constraints](screenshots/Imadojiemu_Mathilda_301834016_Staff_User_Constraints.png) | BR14 | A staff user with no role, and a duplicate staff email |
| [Audit_Log_Constraint](screenshots/Imadojiemu_Mathilda_301834016_Audit_Log_Constraint.png) | BR16 | An audit record with two actors |
