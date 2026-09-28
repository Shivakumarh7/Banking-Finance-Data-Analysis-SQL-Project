-- ============================================================
-- BANKING & FINANCE DATA ANALYSIS - SQL PROJECT
-- File: 01_schema.sql
-- Purpose: Create database schema (tables + relationships)
-- Compatible with: PostgreSQL / MySQL / SQLite (minor syntax notes inline)
-- ============================================================

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS branches;

-- ------------------------------------------------------------
-- BRANCHES
-- ------------------------------------------------------------
CREATE TABLE branches (
    branch_id       INT PRIMARY KEY,
    branch_name     VARCHAR(100) NOT NULL,
    city            VARCHAR(50) NOT NULL,
    state           VARCHAR(50) NOT NULL
);

-- ------------------------------------------------------------
-- CUSTOMERS
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    customer_name   VARCHAR(100) NOT NULL,
    gender          VARCHAR(10),
    dob             DATE,
    city            VARCHAR(50),
    state           VARCHAR(50),
    join_date       DATE NOT NULL
);

-- ------------------------------------------------------------
-- ACCOUNTS  (a customer can hold multiple accounts)
-- ------------------------------------------------------------
CREATE TABLE accounts (
    account_id      INT PRIMARY KEY,
    customer_id     INT NOT NULL,
    branch_id       INT NOT NULL,
    account_type    VARCHAR(20) NOT NULL,   -- Savings, Current, Fixed Deposit
    balance         DECIMAL(14,2) NOT NULL,
    open_date       DATE NOT NULL,
    account_status  VARCHAR(20) NOT NULL,   -- Active, Dormant, Closed
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- ------------------------------------------------------------
-- TRANSACTIONS  (core fact table)
-- ------------------------------------------------------------
CREATE TABLE transactions (
    transaction_id      INT PRIMARY KEY,
    account_id          INT NOT NULL,
    transaction_date    DATE NOT NULL,
    transaction_type    VARCHAR(20) NOT NULL,  -- Deposit, Withdrawal, Transfer, Bill Payment
    amount              DECIMAL(14,2) NOT NULL,
    channel             VARCHAR(20) NOT NULL,  -- ATM, Online, Branch, UPI, Mobile App
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- ------------------------------------------------------------
-- LOANS
-- ------------------------------------------------------------
CREATE TABLE loans (
    loan_id             INT PRIMARY KEY,
    customer_id         INT NOT NULL,
    branch_id           INT NOT NULL,
    loan_type           VARCHAR(20) NOT NULL,  -- Home, Personal, Auto, Education, Business
    loan_amount         DECIMAL(14,2) NOT NULL,
    interest_rate       DECIMAL(5,2) NOT NULL,
    tenure_months       INT NOT NULL,
    start_date          DATE NOT NULL,
    loan_status         VARCHAR(20) NOT NULL,  -- Active, Closed, Defaulted
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- ------------------------------------------------------------
-- CARDS
-- ------------------------------------------------------------
CREATE TABLE cards (
    card_id             INT PRIMARY KEY,
    customer_id         INT NOT NULL,
    card_type           VARCHAR(20) NOT NULL,  -- Debit, Credit
    issue_date          DATE NOT NULL,
    credit_limit        DECIMAL(12,2),         -- NULL for debit cards
    card_status         VARCHAR(20) NOT NULL,  -- Active, Blocked, Expired
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
