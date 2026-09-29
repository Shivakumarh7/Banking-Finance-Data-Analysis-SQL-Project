-- ============================================================
-- BANKING & FINANCE DATA ANALYSIS - SQL PROJECT
-- File: 03_analysis_queries.sql
-- Purpose: 20 business questions answered using SQL
-- Concepts: SELECT/WHERE/ORDER BY, JOINs, GROUP BY/HAVING,
--           Subqueries, CTEs, Window Functions, CASE
-- Note: Written for PostgreSQL / SQLite syntax. MySQL equivalents
--       noted inline as comments where syntax differs.
-- ============================================================


-- Q1. List all customers who joined after 2022-01-01, sorted by join date.
SELECT customer_name, city, join_date
FROM customers
WHERE join_date > '2022-01-01'
ORDER BY join_date;


-- Q2. How many accounts exist for each account type?
SELECT account_type, COUNT(*) AS account_count
FROM accounts
GROUP BY account_type
ORDER BY account_count DESC;


-- Q3. List the 10 most recent transactions with the customer's name (simple JOIN).
SELECT
    t.transaction_id,
    c.customer_name,
    t.transaction_date,
    t.transaction_type,
    t.amount
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
JOIN customers c ON c.customer_id = a.customer_id
ORDER BY t.transaction_date DESC
LIMIT 10;


-- Q4. What is the count of transactions by channel (ATM, Online, UPI, etc.)?
SELECT channel, COUNT(*) AS txn_count
FROM transactions
GROUP BY channel
ORDER BY txn_count DESC;


-- Q5. What is the average loan amount for each loan type?
SELECT
    loan_type,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM loans
GROUP BY loan_type
ORDER BY avg_loan_amount DESC;


-- Q6. What is the total deposit amount vs total withdrawal amount?
SELECT
    transaction_type,
    ROUND(SUM(amount), 2) AS total_amount,
    COUNT(*) AS txn_count
FROM transactions
WHERE transaction_type IN ('Deposit', 'Withdrawal')
GROUP BY transaction_type;


-- Q7. What is the month-over-month transaction volume (₹ amount) trend?
SELECT
    STRFTIME('%Y-%m', transaction_date) AS txn_month,   -- MySQL: DATE_FORMAT(transaction_date, '%Y-%m')
    ROUND(SUM(amount), 2) AS monthly_volume,
    COUNT(*) AS txn_count
FROM transactions
GROUP BY txn_month
ORDER BY txn_month;


-- Q8. Who are the top 5 customers by total transaction amount?
SELECT
    c.customer_name,
    ROUND(SUM(t.amount), 2) AS total_txn_amount
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
JOIN transactions t ON t.account_id = a.account_id
GROUP BY c.customer_name
ORDER BY total_txn_amount DESC
LIMIT 5;


-- Q9. What is the total loan amount and average interest rate, by loan type and status?
SELECT
    loan_type,
    loan_status,
    COUNT(*) AS num_loans,
    ROUND(SUM(loan_amount), 2) AS total_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM loans
GROUP BY loan_type, loan_status
ORDER BY loan_type, loan_status;


-- Q10. Which customers hold more than one active loan? (GROUP BY + HAVING)
SELECT
    c.customer_name,
    COUNT(l.loan_id) AS active_loan_count
FROM customers c
JOIN loans l ON l.customer_id = c.customer_id
WHERE l.loan_status = 'Active'
GROUP BY c.customer_name
HAVING COUNT(l.loan_id) > 1;


-- Q11. What percentage of total transaction volume happens on each channel?
SELECT
    channel,
    ROUND(SUM(amount), 2) AS channel_volume,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM transactions), 2) AS pct_of_total_volume
FROM transactions
GROUP BY channel
ORDER BY channel_volume DESC;


-- Q12. Which customers have never made a single transaction? (LEFT JOIN + IS NULL)
SELECT
    c.customer_name,
    c.join_date
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON t.account_id = a.account_id
WHERE t.transaction_id IS NULL
GROUP BY c.customer_name, c.join_date;


-- Q13. What is the total account balance held at each branch?
SELECT
    b.branch_name,
    b.city,
    COUNT(a.account_id) AS num_accounts,
    ROUND(SUM(a.balance), 2) AS total_balance
FROM branches b
JOIN accounts a ON a.branch_id = b.branch_id
WHERE a.account_status = 'Active'
GROUP BY b.branch_name, b.city
ORDER BY total_balance DESC;


-- Q14. Rank customers by total account balance within each branch (window function).
SELECT
    branch_name,
    customer_name,
    total_balance,
    RANK() OVER (PARTITION BY branch_name ORDER BY total_balance DESC) AS balance_rank_in_branch
FROM (
    SELECT
        b.branch_name,
        c.customer_name,
        SUM(a.balance) AS total_balance
    FROM customers c
    JOIN accounts a ON a.customer_id = c.customer_id
    JOIN branches b ON b.branch_id = a.branch_id
    WHERE a.account_status = 'Active'
    GROUP BY b.branch_name, c.customer_name
) balances
ORDER BY branch_name, balance_rank_in_branch;


-- Q15. What is the running (cumulative) monthly deposit total for 2024?
SELECT
    txn_month,
    monthly_deposits,
    SUM(monthly_deposits) OVER (ORDER BY txn_month) AS cumulative_deposits
FROM (
    SELECT
        STRFTIME('%Y-%m', transaction_date) AS txn_month,
        ROUND(SUM(amount), 2) AS monthly_deposits
    FROM transactions
    WHERE transaction_type = 'Deposit'
      AND STRFTIME('%Y', transaction_date) = '2024'
    GROUP BY txn_month
) monthly
ORDER BY txn_month;


-- Q16. What is the month-over-month transaction volume growth rate? (LAG window function)
SELECT
    txn_month,
    monthly_volume,
    LAG(monthly_volume) OVER (ORDER BY txn_month) AS prev_month_volume,
    ROUND(
        100.0 * (monthly_volume - LAG(monthly_volume) OVER (ORDER BY txn_month))
        / NULLIF(LAG(monthly_volume) OVER (ORDER BY txn_month), 0)
    , 2) AS mom_growth_pct
FROM (
    SELECT
        STRFTIME('%Y-%m', transaction_date) AS txn_month,
        ROUND(SUM(amount), 2) AS monthly_volume
    FROM transactions
    GROUP BY txn_month
) monthly
ORDER BY txn_month;


-- Q17. Customer segmentation by balance & activity level (CTE + CASE).
--      Segments: Premium (high balance + active), Standard, Low Activity, Dormant Risk
WITH customer_activity AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(a.balance) AS total_balance,
        COUNT(DISTINCT t.transaction_id) AS txn_count,
        MAX(t.transaction_date) AS last_txn_date
    FROM customers c
    JOIN accounts a ON a.customer_id = c.customer_id
    LEFT JOIN transactions t ON t.account_id = a.account_id
    WHERE a.account_status = 'Active'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_name,
    ROUND(total_balance, 2) AS total_balance,
    txn_count,
    last_txn_date,
    CASE
        WHEN total_balance > 200000 AND txn_count >= 8 THEN 'Premium'
        WHEN txn_count >= 4 THEN 'Standard'
        WHEN txn_count BETWEEN 1 AND 3 THEN 'Low Activity'
        ELSE 'Dormant Risk'
    END AS customer_segment
FROM customer_activity
ORDER BY total_balance DESC;


-- Q18. Average transaction amount by channel, ranked (window function).
SELECT
    channel,
    txn_count,
    avg_txn_amount,
    RANK() OVER (ORDER BY avg_txn_amount DESC) AS avg_amount_rank
FROM (
    SELECT
        channel,
        COUNT(*) AS txn_count,
        ROUND(AVG(amount), 2) AS avg_txn_amount
    FROM transactions
    GROUP BY channel
) t;


-- Q19. What is the loan default rate by loan type? (correlated ratio calculation)
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_pct
FROM loans
GROUP BY loan_type
ORDER BY default_rate_pct DESC;


-- Q20. Top borrower (by loan amount) per branch (ROW_NUMBER window function).
SELECT
    branch_name,
    customer_name,
    loan_amount,
    loan_type
FROM (
    SELECT
        b.branch_name,
        c.customer_name,
        l.loan_amount,
        l.loan_type,
        ROW_NUMBER() OVER (PARTITION BY b.branch_name ORDER BY l.loan_amount DESC) AS rn
    FROM loans l
    JOIN customers c ON c.customer_id = l.customer_id
    JOIN branches b ON b.branch_id = l.branch_id
) ranked
WHERE rn = 1
ORDER BY loan_amount DESC;
