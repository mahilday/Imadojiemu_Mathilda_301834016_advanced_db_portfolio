# Advanced Database Systems Portfolio - MIT 8103

**Student:** Mathilda Imadojiemu
**Student ID:** 301834016

Banking database setup portfolio

## Contents

| # | Portfolio | Contents | Status |
| --- | --- | --- | --- |
| 1 | [Database design and modelling](portfolio-1-database-design/) | Case study, business rules, ER diagram, relational schema, constraints, normalisation | Complete |
| 2 | [Query processing and optimisation](portfolio-2-query-optimisation/) | SQL queries, execution plans, indexing, performance analysis | In progress |
| 3 | [Transactions and concurrency](portfolio-3-transactions-concurrency/) | Commit, rollback, isolation levels, concurrency control | Not started |
| 4 | [NoSQL and advanced data models](portfolio-4-nosql/) | NoSQL model of the same case study, implementation, suitability | Not started |
| 5 | [Distributed and cloud database](portfolio-5-distributed-cloud/) | Replication, sharding, availability, consistency | Not started |

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



