-- Star Bank business queries (Portfolio 2)
-- Run against the star_bank database after the Portfolio 1 schema and sample data.
-- Each query answers a question the bank's staff or members would ask.

-- Q1: Account statement
-- Every entry on one account, newest first. Joins three tables.
SELECT t.reference,
       t.type   AS transaction_type,
       le.type  AS entry_type,
       le.amount,
       t.status,
       t.created_at
FROM account a
JOIN ledger_entry le ON le.account_id = a.account_id
JOIN transaction t   ON t.transaction_id = le.transaction_id
WHERE a.account_number = '0100000001'
ORDER BY t.created_at DESC, t.reference DESC;

-- Q2: Money in and money out per member
-- Totals credits and debits across all of a member's accounts.
-- LEFT JOIN keeps members who have no entries yet.
SELECT m.full_name,
       m.country,
       count(DISTINCT a.account_id) AS accounts,
       COALESCE(sum(le.amount) FILTER (WHERE le.type = 'CREDIT'), 0) AS total_credits,
       COALESCE(sum(le.amount) FILTER (WHERE le.type = 'DEBIT'), 0)  AS total_debits
FROM member m
JOIN account a            ON a.member_id = m.member_id
LEFT JOIN ledger_entry le ON le.account_id = a.account_id
GROUP BY m.member_id, m.full_name, m.country
ORDER BY m.full_name;

-- Q3: Transactions that need attention
-- Failed and pending transactions, for the support team to review.
SELECT reference, type, amount, currency, status, created_at
FROM transaction
WHERE status IN ('FAILED', 'PENDING')
ORDER BY created_at DESC, reference;

-- Q4: Bill payments per biller
-- LEFT JOIN keeps billers that have received no payments, shown as zero.
SELECT b.name AS biller,
       b.category,
       b.country,
       count(t.transaction_id)    AS payments,
       COALESCE(sum(t.amount), 0) AS total_paid
FROM biller b
LEFT JOIN transaction t
       ON t.biller_id = b.biller_id
      AND t.status = 'COMPLETED'
GROUP BY b.biller_id, b.name, b.category, b.country
ORDER BY total_paid DESC, b.name;

-- Q5: Balance audit
-- Compares each stored balance with the total of the account's ledger entries.
-- Every row should show matches = true.
SELECT a.account_number,
       a.currency,
       a.balance AS stored_balance,
       COALESCE(sum(CASE WHEN le.type = 'CREDIT' THEN le.amount ELSE -le.amount END), 0) AS ledger_balance,
       a.balance = COALESCE(sum(CASE WHEN le.type = 'CREDIT' THEN le.amount ELSE -le.amount END), 0) AS matches
FROM account a
LEFT JOIN ledger_entry le ON le.account_id = a.account_id
GROUP BY a.account_id, a.account_number, a.currency, a.balance
ORDER BY a.account_number;

-- Q6: Running balance on one account
-- A window function adds up the entries in order, showing the balance after each one.
SELECT t.reference,
       le.type AS entry_type,
       le.amount,
       sum(CASE WHEN le.type = 'CREDIT' THEN le.amount ELSE -le.amount END)
           OVER (ORDER BY t.reference) AS running_balance
FROM account a
JOIN ledger_entry le ON le.account_id = a.account_id
JOIN transaction t   ON t.transaction_id = le.transaction_id
WHERE a.account_number = '0100000001'
ORDER BY t.reference;

-- Q7: Reversals and the transactions they reversed
-- A self-join: the transaction table is joined to itself.
SELECT original.reference AS original_reference,
       original.type      AS original_type,
       original.amount,
       original.status    AS original_status,
       reversal.reference AS reversal_reference,
       reversal.status    AS reversal_status
FROM transaction reversal
JOIN transaction original
  ON original.transaction_id = reversal.reverse_transaction_id
ORDER BY original.reference;