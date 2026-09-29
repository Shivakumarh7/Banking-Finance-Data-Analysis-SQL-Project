# 📊 Query Results & Business Analysis

This document walks through all 20 SQL queries from this project the way an analyst would present them to a business stakeholder: **what was asked → how it was solved → what came back → what it means for the business.**

Screenshots are from SQL Server Management Studio (SSMS), run against the dataset in `02_sample_data.sql`.

---

### Q1. Which new customers joined after Jan 2022?
**Business ask:** *"Marketing wants a list of customers who joined after 2022-01-01, ranked by how recently they joined, so we can target them with an onboarding/loyalty campaign."*

**Approach:** Simple `WHERE` filter on `join_date` with `ORDER BY` — no joins needed since everything lives in `customers`.

![Q1](screenshots/Q1.png)

**Business takeaway:** This list becomes the seed audience for a "Welcome" email/SMS journey. Sorting by join date means the newest customers (still in their first 90 days, when churn risk is highest) surface first.

---

### Q2. How many accounts exist per account type?
**Business ask:** *"Product wants to know our account mix — are we mostly a savings bank, or do Current and Fixed Deposit pull their weight?"*

**Approach:** `GROUP BY account_type` with `COUNT(*)`.

![Q2](screenshots/Q2.png)

**Business takeaway:** Savings dominates (170 accounts) vs. Current (77) and Fixed Deposit (68). That tells Product the bank's core relationship is transactional/savings-led — any new feature (like a savings round-up tool) will reach the widest audience, while FD products need a dedicated push to grow share.

---

### Q3. What are the 10 most recent transactions, with customer names?
**Business ask:** *"Operations needs a live feed of the latest transactions with customer names attached, for daily reconciliation."*

**Approach:** 3-table `JOIN` (`transactions` → `accounts` → `customers`), sorted by date descending, `TOP 10`.

![Q3](screenshots/Q3.png)

**Business takeaway:** This is the exact pattern used to build a reconciliation or fraud-monitoring dashboard — the same join logic scales to "show me all transactions in the last hour" for a real-time ops screen.

---

### Q4. How many transactions happen on each channel?
**Business ask:** *"Digital banking wants to know which channels (ATM, UPI, Online, etc.) customers actually use, to prioritize where we invest."*

**Approach:** `GROUP BY channel`, `COUNT(*)`, sorted descending.

![Q4](screenshots/Q4.png)

**Business takeaway:** UPI leads with 622 transactions, well ahead of Mobile App (445) and Online (421), with Branch lowest (217). This justifies further UPI feature investment (like UPI Autopay) over expanding physical branch banking hours.

---

### Q5. What's the average loan amount by loan type?
**Business ask:** *"Lending wants typical ticket sizes per loan product, for portfolio planning and marketing collateral."*

**Approach:** `GROUP BY loan_type`, `AVG(loan_amount)`.

![Q5](screenshots/Q5.png)

**Business takeaway:** Home loans average ~₹36.8 lakh, dwarfing Personal loans (~₹4.5 lakh). This confirms Home loans are the balance-sheet-heavy product — useful context before looking at *default* rates later (Q19), since a Home loan default carries much more capital risk than a Personal loan default.

---

### Q6. What's the total deposit amount vs. withdrawal amount?
**Business ask:** *"Finance wants to know if we have healthy net inflows or if customers are pulling more money out than they're putting in."*

**Approach:** Filter to `Deposit`/`Withdrawal`, `GROUP BY transaction_type`, `SUM(amount)`.

![Q6](screenshots/Q6.png)

**Business takeaway:** Deposits (~₹2.01 crore) outpace withdrawals (~₹77.8 lakh) by a healthy margin — a strong net-inflow signal. This is one of the first numbers a CFO would want on a monthly dashboard.

---

### Q7. What's the month-over-month transaction volume trend?
**Business ask:** *"Leadership wants to see if transaction volume is growing, flat, or seasonal, month by month."*

**Approach:** `GROUP BY` formatted month, `SUM(amount)`, `COUNT(*)`, ordered chronologically.

![Q7](screenshots/Q7.png)

**Business takeaway:** Volume fluctuates rather than trending cleanly upward — useful for forecasting and staffing (e.g., higher-volume months may need more branch/support staff).

---

### Q8. Who are the top 5 customers by transaction volume?
**Business ask:** *"Relationship managers want their VIP list — who is moving the most money through the bank?"*

**Approach:** 3-table `JOIN`, `GROUP BY customer_name`, `SUM(amount)`, `TOP 5`.

![Q8](screenshots/Q8.png)

**Business takeaway:** Kiran Rao tops the list at ~₹6.93 lakh in transaction volume. These five names go straight to the relationship management team for premium servicing — losing one of them would materially hurt engagement metrics.

---

### Q9. What does the loan portfolio look like by type and status?
**Business ask:** *"Risk and Finance need a full breakdown: how much is lent out per loan type, split by Active/Closed/Defaulted, plus the average rate we're charging."*

**Approach:** `GROUP BY loan_type, loan_status`, multiple aggregates.

![Q9](screenshots/Q9.png)

**Business takeaway:** This is a portfolio health snapshot in one query — e.g., Business loans show ₹6.98 crore active exposure at a 12.1% average rate. Any pattern where Defaulted rows carry a disproportionate share of loan value flags a segment needing tighter underwriting.

---

### Q10. Which customers hold more than one active loan?
**Business ask:** *"Credit risk wants to flag customers with multiple concurrent loans — that's concentration risk if one customer defaults on everything at once."*

**Approach:** `JOIN` + `GROUP BY customer_name` + `HAVING COUNT(loan_id) > 1`.

![Q10](screenshots/Q10.png)

**Business takeaway:** These customers (e.g., Kritika Gupta with 3 active loans) need closer credit monitoring — multiple loans per customer increases exposure per relationship and should factor into loan-approval decisions going forward.

---

### Q11. What % of transaction volume happens on each channel?
**Business ask:** *"Same channel question as Q4, but by ₹ value, not just count — a few large branch transactions could matter more than many small UPI ones."*

**Approach:** `SUM(amount)` per channel ÷ total `SUM(amount)` (subquery), as a percentage.

![Q11](screenshots/Q11.png)

**Business takeaway:** UPI still leads by value (29.69%), but Branch punches above its transaction-count weight in ₹ terms (11.39% of value from only 217 transactions) — meaning branch transactions tend to be higher-ticket. This nuance (count vs. value) is exactly the kind of insight that makes an analyst stand out.

---

### Q12. Which customers have never made a transaction?
**Business ask:** *"Retention wants a dormant-customer list — people who opened an account but never actually used it — for a re-engagement campaign."*

**Approach:** `LEFT JOIN` from `customers` → `transactions`, filter `WHERE transaction_id IS NULL`.

![Q12](screenshots/Q12.png)

**Business takeaway:** These customers are pure acquisition cost with zero activity — the perfect audience for a "activate your account" incentive campaign before they're written off as churned.

---

### Q13. What's the total account balance held at each branch?
**Business ask:** *"Branch operations wants deposit totals per branch, to guide staffing and marketing budget allocation."*

**Approach:** `JOIN branches` → `accounts`, filter `Active`, `GROUP BY branch_name, city`.

![Q13](screenshots/Q13.png)

**Business takeaway:** Andheri Branch (Mumbai) holds the highest total balance (~₹65.1 lakh) despite not having the most accounts — meaning it serves a higher-value customer base per account. That's a case for premium/wealth-management staffing at that specific branch.

---

### Q14. How do customers rank by balance within their own branch?
**Business ask:** *"Each branch manager wants their own top depositors ranked — not a bank-wide list, a per-branch leaderboard."*

**Approach:** `RANK() OVER (PARTITION BY branch_name ORDER BY total_balance DESC)` — a window function, on top of a `GROUP BY` subquery.

![Q14](screenshots/Q14.png)

**Business takeaway:** This is the query that scales to "give every branch manager their own top-10 list" in one shot — instead of writing 6 separate queries (one per branch), the `PARTITION BY` does it all at once. That's the kind of efficiency interviewers specifically look for.

---

### Q15. What's the cumulative (running total) deposit trend for 2024?
**Business ask:** *"Finance wants to track deposits building up month by month against an annual target — not just each month in isolation."*

**Approach:** `SUM(monthly_deposits) OVER (ORDER BY txn_month ROWS UNBOUNDED PRECEDING)` — a running total window function.

![Q15](screenshots/Q15.png)

**Business takeaway:** By May 2024, cumulative deposits had already crossed ₹41.3 lakh. Plotting this against an annual target line (e.g., ₹1 crore) instantly shows whether the bank is pacing ahead or behind — a classic finance dashboard visual.

---

### Q16. What's the month-over-month transaction growth rate?
**Business ask:** *"Leadership doesn't just want raw volume — they want the % change each month, to catch sudden drops or spikes early."*

**Approach:** `LAG(monthly_volume) OVER (ORDER BY txn_month)` to pull the previous month's value into the same row, then compute % change.

![Q16](screenshots/Q16.png)

**Business takeaway:** February 2023 shows a -25.24% drop versus January — a red flag that would normally trigger a root-cause conversation (Was it a holiday month? A system outage? A seasonal dip?). This is the query that turns raw numbers into an early-warning system.

---

### Q17. How do we segment customers by value and activity? (RFM-style)
**Business ask:** *"Marketing and Risk both want the same thing from different angles: which customers are our most valuable and active (Premium), which are drifting (Low Activity), and which look like churn/dormancy risks?"*

**Approach:** `CTE` to pre-aggregate balance + transaction count + last transaction date per customer, then a `CASE` statement layers segmentation logic on top.

![Q17](screenshots/Q17.png)

**Business takeaway:** Customers like Nisha Bhat (₹72 lakh balance, 25 transactions) land in "Premium" — the segment that should get relationship managers, fee waivers, and priority support. This single query could directly drive a CRM tagging job that feeds email/SMS campaign targeting.

---

### Q18. What's the average transaction size by channel, ranked?
**Business ask:** *"Ops wants to know: are branch transactions really bigger-ticket than digital ones, or does it just feel that way?"*

**Approach:** `GROUP BY channel` aggregate, wrapped in a `RANK() OVER (ORDER BY avg_txn_amount DESC)`.

![Q18](screenshots/Q18.png)

**Business takeaway:** Confirmed — Branch has the highest average transaction size (₹19,925.87), ahead of Mobile App and UPI. This supports Q11's finding and makes a clear case: don't shut down branches even as digital volume grows, because they still handle disproportionately large transactions.

---

### Q19. What's the loan default rate by loan type?
**Business ask:** *"Risk management's #1 question: which loan products are riskiest, and should we tighten approval criteria there?"*

**Approach:** `SUM(CASE WHEN loan_status = 'Defaulted' THEN 1 ELSE 0 END)` divided by total count, per loan type.

![Q19](screenshots/Q19.png)

**Business takeaway:** Business loans default at 14.29% — more than 5x the rate of Personal loans (2.63%). This is the single most "board-meeting-ready" insight in the whole project: it directly supports tightening underwriting criteria specifically for Business loans, rather than a blanket policy change.

---

### Q20. Who is the single largest borrower at each branch?
**Business ask:** *"Each branch manager wants to know their single biggest loan exposure — the one customer whose default would hurt the most."*

**Approach:** `ROW_NUMBER() OVER (PARTITION BY branch_name ORDER BY loan_amount DESC)`, filtered to `rn = 1`.

![Q20](screenshots/Q20.png)

**Business takeaway:** Connaught Place Branch's top exposure is a ₹59.99 lakh Home loan. Flagging the single largest exposure per branch is standard practice in concentration-risk reporting — this query is the SQL equivalent of a risk officer's watchlist.

---

## 🎯 Why this matters for the role

Every query above follows the same discipline: **a real business question → the right SQL technique → a number → what to *do* with that number.** That last step — connecting SQL output to a business decision — is what separates someone who can write queries from someone who can actually do data analysis. That's the story this project is built to tell.
