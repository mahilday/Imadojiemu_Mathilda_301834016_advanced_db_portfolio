# Portfolio 4: NoSQL and Advanced Data Models

For this portfolio I rebuilt part of the Star Bank database in MongoDB, a document database, to see what changes when the same data is stored as documents instead of tables, and whether that would suit a bank.

## How I built and tested it

- MongoDB 7 running in a Docker container, with `mongosh` as the shell.
- One script, [Star_Bank_Mongo_Documents](Imadojiemu_Mathilda_301834016_Star_Bank_Mongo_Documents.js), creates the collections, loads the same members and transactions as my Portfolio 1 sample data, and runs the queries and tests.
- The full output of a run is in [Output](Imadojiemu_Mathilda_301834016_Output.txt).
- I checked each result against the PostgreSQL results from Portfolios 1 and 2.

Setup steps are in [P4_SETUP](Imadojiemu_Mathilda_301834016_P4_SETUP.md).

## Why a document database

I picked the document type because Star Bank's data is naturally nested: a member has accounts, and a transaction has ledger entries. A key-value store can't search inside its values, a wide-column store is built for far larger histories than this, and a graph database answers a different kind of question, such as tracing links between accounts for fraud.

## The model

Two collections do the work of six relational tables.

| Collection | Replaces | How |
| --- | --- | --- |
| `members` | `member`, `account` | Each member holds an `accounts` array |
| `transactions` | `transaction`, `ledger_entry`, part of `biller` | Each transaction holds its `entries`, a `details` object, and the biller for bill payments |

The main decision was what to embed and what to keep separate:

- **Accounts go inside the member**, because a member has only a few and they are read together.
- **Entries go inside the transaction**, because an entry means nothing without it.
- **The biller's name is copied into the bill payment**, so a statement shows the name as it was on the day.
- **Transactions are not put inside the member.** An account can have thousands, and the member document would grow without limit. They point to the account by `account_number` instead.

### One transfer, two ways

In PostgreSQL a transfer is spread over three tables and needs two joins to read. In MongoDB it is a single document:

```javascript
{
  reference: 'TXN-0004',
  type: 'TRANSFER',
  amount: Decimal128('10000.00'),
  currency: 'NGN',
  status: 'COMPLETED',
  created_at: ISODate('2026-11-03T12:00:00Z'),
  details: { narration: 'Payment for fabric supplies' },
  entries: [
    { account_number: '0100000001', type: 'DEBIT',  amount: Decimal128('10000.00') },
    { account_number: '0100000003', type: 'CREDIT', amount: Decimal128('10000.00') }
  ]
}
```

The `details` field is different for each kind of transaction: a narration for a transfer, a meter number for an electricity payment, a failure reason for a failed withdrawal. In my relational schema that would have needed extra nullable columns.

### Keeping the rules

MongoDB doesn't enforce a structure unless you ask it to, so I added my Portfolio 1 rules back using `$jsonSchema` validation and unique indexes: allowed countries, currencies, types and statuses, no negative balance, no zero amount, and unique emails and account numbers. Money is stored as `Decimal128` so it stays exact.

## Results

| Query | Result |
| --- | --- |
| Q1: a member with all accounts | Adaeze's document with both accounts, in one read |
| Q2: statement for account 0100000001 | TXN-0009, 0008, 0005, 0004, 0001 |
| Q3: failed and pending | TXN-0010, INSUFFICIENT_FUNDS |
| Q4: completed, by type and currency | Six groups, for example NGN deposits: 2 totalling 70,000.00 |
| Q5: ledger balance per account | 35,000.00, 0.00, 27,000.00, 11,000.00, 4,000.00 |
| Q6: bill payments | TXN-0005, Lagos Power Distribution |

Q2 gives the same five transactions as my statement query in Portfolio 2, and Q5 gives the same balances as my Portfolio 1 audit.

All three validation tests were rejected, as intended: a member in Ghana and a zero-amount transaction failed validation, and a duplicate email hit the unique index.

The query plan for the statement shows `IXSCAN`, so it used my index. It is a multikey index, meaning it indexes each value inside the `entries` array, which is how a transfer can be found from either account.

## Does it suit Star Bank?

Partly.

**It works well for reading.** The app's most common request is "show my recent transactions", and here each one is a complete document with no joins. New transaction types can add fields without changing a table. Audit logs and notifications, which are written once and vary in shape, fit well too.

**It is weaker for moving money.** A transfer changes two balances that may sit in two different member documents. MongoDB can wrap that in a transaction, but PostgreSQL is built around it, which is what I relied on in Portfolio 3. There is also duplication: the biller's name is copied into every payment and nothing keeps the copies in step, which is the problem normalisation solved in Portfolio 1. And the validator only checks one document at a time, so it cannot confirm that a bill payment's biller exists, the way a foreign key did.

**My recommendation is to use both.** PostgreSQL stays the system of record for accounts, balances and transfers. MongoDB holds a read copy for statements, activity feeds, notifications and audit history. The trade-off is that the copy can be slightly behind, which is fine for a statement screen but not for deciding whether a withdrawal is allowed.

## Limits

- Ten transactions show the model, not how it performs at scale.
- I loaded the data directly; I did not build the process that would keep the two databases in step.

## Evidence

| Required | Where |
| --- | --- |
| NoSQL model of the same case study | "The model" above; sections 1 and 3 of the [script](Imadojiemu_Mathilda_301834016_Star_Bank_Mongo_Documents.js) |
| Document example | TXN-0004 above |
| Implementation evidence | [Output](Imadojiemu_Mathilda_301834016_Output.txt) |
| Explanation of suitability | [Does it work](#does-it-suit-star-bank) above |