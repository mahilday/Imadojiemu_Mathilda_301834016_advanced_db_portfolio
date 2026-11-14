# Portfolio 3: Transactions and Concurrency

This portfolio uses the Star Bank database from Portfolio 1. It shows how database transactions keep a movement of money correct when it succeeds, when it fails, and when two happen at the same time. This demonstrates the ACID properties in real time.

**Status:** Complete.

A note on wording: Star Bank has a table named `transaction`, which records banking transactions. In this document, "database transaction" always means a group of SQL statements between `BEGIN` and `COMMIT` or `ROLLBACK`.

## How this was implemented and tested

- **Database:** PostgreSQL, accessed through the pgAdmin Query Tool, database `star_bank`, using the Portfolio 1 schema and sample data.
- **Auto-commit** was turned on in the Query Tool, so a database transaction exists only where a script opens one with `BEGIN`.
- **Method:** each script was run one block at a time, checking account balances before, during and after with screenshots as evidence.
- **Two sessions:** the concurrency demonstration used two Query Tool tabs, each with its own connection to the database. In the screenshot names, Session 1 is Session A and Session 2 is Session B.
- **Accounts used:** 0100000001 (Adaeze Okafor) and 0100000003 (Tunde Bakare), both NGN.

## Why a transfer needs a database transaction

A transfer on the Star Bank schema is five separate changes:

1. Insert the row in `transaction`.
2. Insert the debit row in `ledger_entry`.
3. Insert the credit row in `ledger_entry`.
4. Subtract the amount from the sender's balance.
5. Add the amount to the receiver's balance.

If only some of these happen, money is lost or created. A database transaction makes them succeed together or fail together.

## Part 1: Commit

Script: [Commit_Part_1](Imadojiemu_Mathilda_301834016_Commit_Part_1.sql)

A transfer of 1,000 NGN from account 0100000001 to account 0100000003, wrapped in `BEGIN` and `COMMIT`.

| Account    | Before    | After     |
| ---------- | --------- | --------- |
| 0100000001 | 35,000.00 | 34,000.00 |
| 0100000003 | 27,000.00 | 28,000.00 |
| Total      | 62,000.00 | 62,000.00 |

All five changes were saved together. The total across both accounts is unchanged, so money moved and none was created or lost. After `COMMIT` the changes are permanent and visible to every other connection.

## Part 2: Rollback

Script: [Rollback](Imadojiemu_Mathilda_301834016_Rollback.sql)

A transfer of 50,000 NGN from account 0100000001, which held only 34,000. The script credits the receiver first, to show the unsafe state that exists in the middle of a transfer.

| Step                                     | What happened                                                           | 0100000001 | 0100000003 |
| ---------------------------------------- | ----------------------------------------------------------------------- | ---------- | ---------- |
| Before                                   |                                                                         | 34,000.00  | 28,000.00  |
| Inside the transaction, after the credit | Receiver credited; sender not yet debited                               | 34,000.00  | 78,000.00  |
| Debit attempted                          | Rejected by `account_balance_check` (BR6: a balance cannot be negative) |            |            |
| After `ROLLBACK`                         | Every change undone                                                     | 34,000.00  | 28,000.00  |

After the rollback, a count of rows with reference TXN-0012 returned 0: the transaction row and both ledger entries were removed along with the credit.

Two points this shows:

- **The in-between state was never visible outside the transaction.** The 78,000.00 balance existed only inside the open transaction.
- **A failed statement stops the transaction.** After the error, PostgreSQL refused further statements until the transaction was ended with `ROLLBACK`.

### Rollback and reversal are different

The case study operation "reverse failed transactions" covers two situations:

| Situation                                       | Mechanism                                                                                                         |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| A transfer fails while it is being processed    | `ROLLBACK`: nothing is recorded, as shown above                                                                   |
| A transfer completed and later has to be undone | A new reversing transaction that references the original (BR12), as with TXN-0008 and TXN-0009 in the sample data |

## Part 3: Concurrency issue

Scripts: [Session A](Imadojiemu_Mathilda_301834016_Concurrency_Isolation_1.sql), [Session B](Imadojiemu_Mathilda_301834016_Concurrency_Isolation_2.sql)

Two withdrawals were made from account 0100000003 at the same time, from two separate connections. The account held 28,000.00 NGN.

| Session | Withdrawal | Affordable alone?                              |
| ------- | ---------- | ---------------------------------------------- |
| A       | 20,000.00  | Yes                                            |
| B       | 15,000.00  | Yes                                            |
| Both    | 35,000.00  | No: the account would be overdrawn by 7,000.00 |

This is the concurrency issue. Each session, looking only at the balance it could see, had enough money. If both had been allowed to proceed from the same starting balance, the bank would have paid out more than the account held.

Both sessions ran at the `READ COMMITTED` isolation level, PostgreSQL's default.

### What happened, in order

| Step | Session | Action                                                                                       | Result                                                                         |
| ---- | ------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| A1   | A       | Began a transaction, recorded the withdrawal, reduced the balance by 20,000. Did not commit. | Session A saw 8,000.00                                                         |
| B1   | B       | Began a transaction and read the balance                                                     | Session B saw **28,000.00**                                                    |
| B1   | B       | Recorded its withdrawal and tried to reduce the balance by 15,000                            | The `UPDATE` **waited** and did not complete                                   |
| A2   | A       | Queried `pg_stat_activity` for Session B                                                     | Session B reported as waiting on a `Lock`                                      |
| A2   | A       | Committed                                                                                    | Session A's withdrawal became permanent                                        |
|      | B       | The waiting `UPDATE` resumed against the committed balance of 8,000.00                       | **Rejected** by `account_balance_check`: the balance would have been -7,000.00 |
| B2   | B       | Rolled back                                                                                  | Session B's transaction row and ledger entry were removed                      |

### Final state

| Check                             | Result                                        |
| --------------------------------- | --------------------------------------------- |
| Balance of account 0100000003     | 8,000.00                                      |
| TXN-0013 (Session A, 20,000)      | Recorded, COMPLETED                           |
| TXN-0014 (Session B, 15,000)      | Does not exist                                |
| Balance audit across all accounts | Every stored balance matches its ledger total |

## Part 4: Control mechanism and isolation

The same run shows how PostgreSQL prevented the overdraft, through three things working together.

### Isolation

At step B1, Session B read a balance of 28,000.00 although Session A had already taken 20,000. Under `READ COMMITTED`, a transaction never sees changes that another transaction has not committed. This prevents a dirty read: if Session A had rolled back, the 8,000.00 figure would never have been true, and Session B was right not to see it.

### Row locking

When Session A updated the account row, PostgreSQL locked that row for the rest of Session A's transaction. No extra command was needed; every `UPDATE` takes this lock. Session B's `UPDATE` on the same row therefore had to wait. The wait is visible in two ways: the query in Session B did not return, and `pg_stat_activity` reported Session B's `wait_event_type` as `Lock`.

The lock is what turned two simultaneous withdrawals into two withdrawals in sequence.

### The constraint

Once Session A committed, Session B's `UPDATE` continued using the newly committed balance, not the 28,000.00 it had read earlier. The calculation became 8,000 less 15,000, and the Portfolio 1 constraint `CHECK (balance >= 0)` (BR6) rejected it.

### Limits

- The second withdrawal was rejected with a database error. A real banking application would catch that error and tell the member the withdrawal was declined for insufficient funds.
- The scripts were run by hand in two tabs. In production the same steps would be carried out by application code, many times a second.

## ACID properties shown

| Property    | Meaning                                                | Where it is shown                                                                                           |
| ----------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| Atomicity   | All of a transaction happens, or none of it            | Part 2: the failed transfer left nothing behind                                                             |
| Consistency | A transaction cannot leave the data breaking its rules | Parts 2 and 3: the check constraint rejected a negative balance both times                                  |
| Isolation   | Transactions running at the same time do not interfere | Parts 3 and 4: Session B could not see Session A's uncommitted withdrawal, and had to wait for the row lock |
| Durability  | Committed changes are permanent                        | Part 1: the new balances remain after `COMMIT`                                                              |

## Evidence

| Required evidence                      | File                                                                                                                                                                                               |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Commit                                 | [Commit_Part_1](Imadojiemu_Mathilda_301834016_Commit_Part_1.sql)                                                                                                                                   |
| Rollback                               | [Rollback](Imadojiemu_Mathilda_301834016_Rollback.sql)                                                                                                                                             |
| Isolation                              | [Concurrency_Isolation_1](Imadojiemu_Mathilda_301834016_Concurrency_Isolation_1.sql) (Session A), [Concurrency_Isolation_2](Imadojiemu_Mathilda_301834016_Concurrency_Isolation_2.sql) (Session B) |
| Concurrency issue or control mechanism | The same two session files                                                                                                                                                                         |

### Screenshots: commit and rollback

| Screenshot                                                                                       | What it shows                                      |
| ------------------------------------------------------------------------------------------------ | -------------------------------------------------- |
| [Balance_Before_Transfer](screenshots/Imadojiemu_Mathilda_301834016_Balance_Before_Transfer.png) | Both balances before the committed transfer        |
| [Balance_After_Transfer](screenshots/Imadojiemu_Mathilda_301834016_Balance_After_Transfer.png)   | Both balances after the committed transfer         |
| [Debit_Failed](screenshots/Imadojiemu_Mathilda_301834016_Debit_Failed.png)                       | The debit rejected by the balance check constraint |
| [Balance_After_Rollback](screenshots/Imadojiemu_Mathilda_301834016_Balance_After_Rollback.png)   | Both balances unchanged after the rollback         |
| [Rollback_Proof](screenshots/Imadojiemu_Mathilda_301834016_Rollback_Proof.png)                   | No TXN-0012 row exists after the rollback          |

### Screenshots: concurrency and isolation

| Screenshot                                                                                                                                 | What it shows                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| [After_Session_1_Run_Before_Commit](screenshots/Imadojiemu_Mathilda_301834016_After_Session_1_Run_Before_Commit.png)                       | Session A sees 8,000.00 inside its open transaction               |
| [After_Session_2_Run_Before_Commit](screenshots/Imadojiemu_Mathilda_301834016_After_Session_2_Run_Before_Commit.png)                       | Session B still sees 28,000.00: Session A's change is not visible |
| [Session_B_Transaction_Load](screenshots/Imadojiemu_Mathilda_301834016_Session_B_Transaction_Load.png)                                     | Session B's update waiting to complete                            |
| [Locked_Row_Cannot_Insert](screenshots/Imadojiemu_Mathilda_301834016_Locked_Row_Cannot_Insert.png)                                         | Session B blocked by the lock on the account row                  |
| [Locked_Status](screenshots/Imadojiemu_Mathilda_301834016_Locked_Status.png)                                                               | `pg_stat_activity` reporting Session B as waiting on a `Lock`     |
| [After_Session_1_Commit](screenshots/Imadojiemu_Mathilda_301834016_After_Session_1_Commit.png)                                             | Session A committing its withdrawal                               |
| [Session_B_Load_Result_After_Session_1_Commit](screenshots/Imadojiemu_Mathilda_301834016_Session_B_Load_Result_After_Session_1_Commit.png) | Session B's update rejected by the balance check constraint       |
| [Check_Balance_After_Session_2_Commit](screenshots/Imadojiemu_Mathilda_301834016_Check_Balance_After_Session_2_Commit.png)                 | Final balance of 8,000.00 after Session B rolled back             |
| [Final_Balance_Audit](screenshots/Imadojiemu_Mathilda_301834016_Final_Balance_Audit.png)                                                   | Every stored balance matches its ledger total                     |
