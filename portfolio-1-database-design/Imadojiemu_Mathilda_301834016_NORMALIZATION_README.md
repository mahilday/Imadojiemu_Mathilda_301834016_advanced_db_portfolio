# Star Bank Normalization

Normalization splits data into related tables to reduce repeated details and avoid inconsistent updates. 

**Two members are used as examples for this process**

Only the fields needed to explain the changes are shown; the full design keeps the other fields from the relational schema.

IDs are shortened for readability; the real schema uses UUIDs.

*Note: Names, emails and billers are fictional and come from the sample data.*

## Starting statement list

| member_id | full_name | email | Account activity |
| --- | --- | --- | --- |
| 1 | Adaeze Okafor | adaeze.okafor@mail.example | Account 0100000001 (NGN): TXN-0004 TRANSFER 10000, debit; TXN-0005 BILL_PAYMENT 5000, debit, biller 1 Lagos Power Distribution (Electricity) |
| 2 | Tunde Bakare | tunde.bakare@mail.example | Account 0100000003 (NGN): TXN-0004 TRANSFER 10000, credit; TXN-0006 WITHDRAWAL 3000, debit |

The last column holds several transactions in one cell. Finding one transaction, totalling an account or reversing a payment is awkward. TXN-0004 is a transfer between the two members, so it is written twice, once under each of them.

## 1NF: One value per cell

Each account's part in each transaction has its own row. The repeated list is removed.

| reference | account_number | entry_type | type | amount | biller_id | biller_name | biller_category | currency | member_id | full_name | email |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TXN-0004 | 0100000001 | DEBIT | TRANSFER | 10000 | | | | NGN | 1 | Adaeze Okafor | adaeze.okafor@mail.example |
| TXN-0004 | 0100000003 | CREDIT | TRANSFER | 10000 | | | | NGN | 2 | Tunde Bakare | tunde.bakare@mail.example |
| TXN-0005 | 0100000001 | DEBIT | BILL_PAYMENT | 5000 | 1 | Lagos Power Distribution | Electricity | NGN | 1 | Adaeze Okafor | adaeze.okafor@mail.example |
| TXN-0006 | 0100000003 | DEBIT | WITHDRAWAL | 3000 | | | | NGN | 2 | Tunde Bakare | tunde.bakare@mail.example |

For this example, the key is **(reference, account_number)**. Both values together identify one row. reference alone is not enough: TXN-0004 appears twice, once for each account in the transfer. account_number alone is not enough either: each account appears in two transactions.

The rows are in 1NF, but three problems remain:

- **Update anomaly:** Adaeze's email is repeated on every row for her account. Changing it means changing every one of them.
- **Insert anomaly:** a member who has opened an account but made no transaction cannot be recorded.
- **Delete anomaly:** removing Tunde's only two transactions would remove Tunde.

## 2NF: Details depend on the whole key

2NF includes 1NF. A non-key field must not depend on only part of a combined key. The functional dependencies are:

- **reference → type, amount, biller_id, biller_name, biller_category.** These describe the transaction, whichever account is involved.
- **account_number → currency, member_id, full_name, email.** These describe the account, whichever transaction is involved.
- **(reference, account_number) → entry_type.** Whether a row is a debit or a credit needs both.

The first two groups depend on only part of the key, so each moves into its own table.

### Transaction details

Key: **reference**.

| reference | type | amount | biller_id | biller_name | biller_category |
| --- | --- | --- | --- | --- | --- |
| TXN-0004 | TRANSFER | 10000 | | | |
| TXN-0005 | BILL_PAYMENT | 5000 | 1 | Lagos Power Distribution | Electricity |
| TXN-0006 | WITHDRAWAL | 3000 | | | |

### Account details

Key: **account_number**.

| account_number | currency | member_id | full_name | email |
| --- | --- | --- | --- | --- |
| 0100000001 | NGN | 1 | Adaeze Okafor | adaeze.okafor@mail.example |
| 0100000003 | NGN | 2 | Tunde Bakare | tunde.bakare@mail.example |

### Ledger entries

Key: **(reference, account_number)**. Each part links to one of the tables above.

| reference | account_number | entry_type |
| --- | --- | --- |
| TXN-0004 | 0100000001 | DEBIT |
| TXN-0004 | 0100000003 | CREDIT |
| TXN-0005 | 0100000001 | DEBIT |
| TXN-0006 | 0100000003 | DEBIT |

The transfer's type and amount are now stored once instead of twice. However, a biller's name and category would still repeat on every bill payment made to it, and a member's name and email would still repeat on every account that member holds.

## 3NF: Keep details with the thing they describe

3NF includes 2NF. Non-key fields must not depend on another non-key field. Two remaining links explain the next split:

- **biller_id determines biller_name and biller_category**: these describe the biller, not the transaction.
- **member_id determines full_name and email**: these describe the member, not the account.

### biller

Key: **biller_id**.

| biller_id | name | category |
| --- | --- | --- |
| 1 | Lagos Power Distribution | Electricity |

### transaction

Key: **reference** in this example. biller_id is a foreign key to biller.

| reference | type | amount | biller_id |
| --- | --- | --- | --- |
| TXN-0004 | TRANSFER | 10000 | |
| TXN-0005 | BILL_PAYMENT | 5000 | 1 |
| TXN-0006 | WITHDRAWAL | 3000 | |

### member

Key: **member_id**.

| member_id | full_name | email |
| --- | --- | --- |
| 1 | Adaeze Okafor | adaeze.okafor@mail.example |
| 2 | Tunde Bakare | tunde.bakare@mail.example |

### account

Key: **account_number** in this example. member_id is a foreign key to member.

| account_number | currency | member_id |
| --- | --- | --- |
| 0100000001 | NGN | 1 |
| 0100000003 | NGN | 2 |

### ledger_entry

| reference | account_number | entry_type |
| --- | --- | --- |
| TXN-0004 | 0100000001 | DEBIT |
| TXN-0004 | 0100000003 | CREDIT |
| TXN-0005 | 0100000001 | DEBIT |
| TXN-0006 | 0100000003 | DEBIT |

Now Adaeze's email is stored once in member, and the biller's name is stored once in biller. The keys preserve the links, so a full statement can still be brought together with joins when needed.
