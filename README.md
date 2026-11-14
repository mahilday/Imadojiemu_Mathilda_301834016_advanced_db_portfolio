# Advanced Database Systems Portfolio - MIT 8103

**Student:** Mathilda Imadojiemu
**Student ID:** 301834016

Banking database setup portfolio

## Contents

| #   | Portfolio                                                             | Contents                                                                              | Status      |
| --- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | ----------- |
| 1   | [Database design and modelling](portfolio-1-database-design/)         | Case study, business rules, ER diagram, relational schema, constraints, normalisation | Complete    |
| 2   | [Query processing and optimization](portfolio-2-query-optimization/)  | SQL queries, execution plans, indexing, performance analysis                          | Complete    |
| 3   | [Transactions and concurrency](portfolio-3-transactions-concurrency/) | Commit, rollback, isolation levels, concurrency control                               | Complete    |
| 4   | [No-SQL and advanced data models](portfolio-4-no-sql/)                  | No-SQL model of the same case study, implementation, suitability                       | Complete    |
| 5   | [Distributed and cloud database](portfolio-5-distributed-cloud/)      | Replication, sharding, availability, consistency                                      | Not started |

### Portfolio 1 files

- [Case study and business rules](portfolio-1-database-design/Imadojiemu_Mathilda_301834016_P1_README.md)
- [ER diagram](portfolio-1-database-design/Imadojiemu_Mathilda_301834016_ER_DIAGRAM_README.md)
- [Schema](portfolio-1-database-design/Imadojiemu_Mathilda_301834016_Schema.sql)
- [Sample data](portfolio-1-database-design/Imadojiemu_Mathilda_301834016_Sample_Data.sql)
- [Constraint tests](portfolio-1-database-design/Imadojiemu_Mathilda_301834016_Constraints_tests.sql)
- [Normalisation](portfolio-1-database-design/Imadojiemu_Mathilda_301834016_NORMALIZATION_README.md)
- [Screenshots](portfolio-1-database-design/screenshots/)

### Portfolio 2 files

- [Overview, results and performance analysis](portfolio-2-query-optimization/Imadojiemu_Mathilda_301834016_P2_README.md)
- [Business queries](portfolio-2-query-optimization/Imadojiemu_Mathilda_301834016_Queries.sql)
- [Optimisation experiment](portfolio-2-query-optimization/Imadojiemu_Mathilda_301834016_Optimizations.sql)
- [Screenshots](portfolio-2-query-optimization/screenshots/)

### Portfolio 3 files

- [Overview and explanation](portfolio-3-transaction-concurrency/Imadojiemu_Mathilda_301834016_P3_README.md)
- [Commit](portfolio-3-transaction-concurrency/Imadojiemu_Mathilda_301834016_Commit_Part_1.sql)
- [Rollback](portfolio-3-transaction-concurrency/Imadojiemu_Mathilda_301834016_Rollback.sql)
- [Concurrency and isolation, Session A](portfolio-3-transaction-concurrency/Imadojiemu_Mathilda_301834016_Concurrency_Isolation_1.sql)
- [Concurrency and isolation, Session B](portfolio-3-transaction-concurrency/Imadojiemu_Mathilda_301834016_Concurrency_Isolation_2.sql)
- [Screenshots](portfolio-3-transaction-concurrency/screenshots/)

### Portfolio 4 files

- [Overview and suitability](portfolio-4-no-sql/Imadojiemu_Mathilda_301834016_P4_README.md)
- [Setup and run instructions](portfolio-4-no-sql/Imadojiemu_Mathilda_301834016_P4_SETUP.md)
- [MongoDB script](portfolio-4-no-sql/Imadojiemu_Mathilda_301834016_Star_Bank_Mongo_Documents.js)
- [Output](portfolio-4-no-sql/Imadojiemu_Mathilda_301834016_Output.txt)

## How to run

### Portfolio 1

1. Create a PostgreSQL database named `star_bank`.
2. Run the schema file.
3. Run the sample data file.
4. Run the constraint tests one statement at a time; each should be rejected.

### Portfolio 2

1. Complete the Portfolio 1 steps first.
2. Run the business queries file one query at a time.
3. Run the optimization file one block at a time, in order. It creates its own schema, `performance_p2_test`, and does not change the Portfolio 1 tables.

### Portfolio 3

1. Complete the Portfolio 1 steps first, and turn on auto-commit in the pgAdmin Query Tool.
2. Run the commit file, then the rollback file, one block at a time.
3. Open two Query Tool tabs. Run the Session A and Session B files in the order given in their comments: A1, B1, A2, B2.

### Portfolio 4

Follow the [setup instructions](portfolio-4-no-sql/Imadojiemu_Mathilda_301834016_P4_SETUP.md). It needs Docker only.
