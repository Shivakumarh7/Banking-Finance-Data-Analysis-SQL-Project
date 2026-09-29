# Banking & Finance Data Analysis — SQL Project

An end-to-end SQL portfolio project analyzing a retail bank's customers, accounts, transactions, loans, and cards. Built to demonstrate the full range of SQL skills a data analyst needs — from basic filtering to window functions, customer segmentation, and risk metrics.

## 📌 Problem Statement

A retail bank wants answers to:
- How much money is moving through the bank, and how is it trending?
- Who are the highest-value customers, and how do we segment them?
- Which branches hold the most deposits?
- What does our loan book look like — and where's the default risk concentrated?
- Which customers are inactive or at risk of churn?

This project answers all of it using only SQL, on a realistic (synthetic) relational dataset with **3,000+ rows**.

## 🗂️ Dataset

Synthetic but realistic banking data, spanning **2019–2024**:

| Table | Rows | Description |
|---|---|---|
| `branches` | 6 | Bank branches across 6 Indian cities |
| `customers` | 200 | Customer demographics & join dates |
| `accounts` | 315 | Savings / Current / Fixed Deposit accounts |
| `transactions` | **2,089** | Core transactional fact table (deposits, withdrawals, transfers, bill payments) |
| `loans` | 205 | Home / Personal / Auto / Education / Business loans |
| `cards` | 249 | Debit & credit cards |

**Total: 3,064+ rows.**

**Schema (ER overview):**
```
branches ──< accounts >── customers ──< loans
branches ──< loans          customers ──< cards
accounts ──< transactions
```

## 📁 Files

| File | Purpose |
|---|---|
| `01_schema.sql` | Table definitions + foreign key relationships |
| `02_sample_data.sql` | Insert statements for all sample data (3,000+ rows) |
| `03_analysis_queries.sql` | 20 business questions solved in SQL |
| `Business_Problem_Statement.pdf` | The business context and the 20 questions on their own, no SQL |
| `Banking_SQL_Query_Results.pdf` | Every question, query, screenshot, and business takeaway, as a report |
| **`QUERY_RESULTS.md`** | **⭐ Every query with the business question, approach, screenshot, and business takeaway — start here** |
| `screenshots/` | Query result screenshots (Q1–Q20) referenced in `QUERY_RESULTS.md` |
| `README.md` | This file |

> 👉 **If you only click one link in this repo, make it [`QUERY_RESULTS.md`](./QUERY_RESULTS.md)** — it shows not just the SQL, but the business reasoning behind each query and what a stakeholder would do with the answer.

## 🛠️ How to Run

1. Create a database in PostgreSQL, MySQL, or SQLite.
2. Run `01_schema.sql` to create the tables.
3. Run `02_sample_data.sql` to load sample data.
4. Run any query from `03_analysis_queries.sql`.

> Written primarily for PostgreSQL/SQLite syntax. MySQL equivalents are noted inline as comments where syntax differs (mainly date functions).

## 📊 The 20 Business Questions

**Customer & Growth**
1. Customers who joined after a given date
2. Account count by type
3. Top 5 customers by total transaction amount
4. Customers who never transacted (LEFT JOIN + IS NULL)
5. Customer segmentation — Premium / Standard / Low Activity / Dormant Risk (CTE + CASE)

**Operations & Channels**
6. 10 most recent transactions with customer names
7. Transaction count by channel
8. % of transaction volume by channel
9. Average transaction amount by channel, ranked

**Finance & Performance**
10. Total deposits vs. withdrawals
11. Month-over-month transaction volume trend
12. Cumulative monthly deposits (running total)
13. Month-over-month transaction growth rate (`LAG()`)
14. Total account balance held per branch
15. Customer balance rank within each branch (`RANK() OVER PARTITION BY`)

**Lending & Risk**
16. Loan amount & average interest rate by type and status
17. Average loan amount by loan type
18. Customers with more than one active loan (HAVING)
19. Loan default rate by loan type (risk analysis)
20. Top borrower per branch (`ROW_NUMBER() OVER PARTITION BY`)

## 🔑 SQL Concepts Demonstrated

- `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`
- Multi-table `JOIN`s (INNER, LEFT)
- Aggregate functions (`SUM`, `COUNT`, `AVG`) with `GROUP BY` / `HAVING`
- Subqueries — scalar and correlated-style ratio calculations
- **CTEs** (`WITH` clauses) for layered, readable logic
- **Window functions**: `RANK()`, `ROW_NUMBER()`, `LAG()`, running totals with `SUM() OVER()`
- `CASE` statements for customer segmentation and risk flags
- Date/time functions for trend and cohort-style analysis

## 💡 Key Findings (from the generated dataset)

- **UPI is the dominant transaction channel** by volume of transactions, though branch transactions tend to be larger individually.
- A small **"Premium"** customer segment — high balance and highly active — holds a disproportionate share of total deposits, a classic 80/20 pattern worth protecting with retention offers.
- **Personal and Business loans show the highest default rates**, while Home loans are the most stable — useful signal for underwriting policy.
- A meaningful group of customers have open accounts but **zero recorded transactions**, flagging them as dormant-risk / re-engagement targets.
- One branch holds significantly more total deposits than others, suggesting either a wealthier customer base or an opportunity to replicate that branch's acquisition strategy elsewhere.

## 🚀 Possible Extensions

- Connect this schema to Tableau/Power BI for an executive dashboard.
- Add a `credit_score` column to customers and correlate it with loan default rates.
- Build a fraud-detection query flagging unusually large or rapid-fire transactions per account.

---
*This is an original project — schema, dataset, and all 20 queries were custom-built and tested end-to-end for portfolio purposes.*
