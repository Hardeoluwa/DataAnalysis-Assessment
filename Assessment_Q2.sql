-- ------------------------------------------
-- Transaction Frequency Analysis
-- Objective:
-- 1. Calculate the average number of monthly transactions per customer
-- 2. Categorize customers as High, Medium, or Low frequency users
-- 3. Output the number of customers in each category and their average transaction frequency

-- ------------------------------------------

-- Step 1: Filter and count monthly transactions for each customer in the last 12 months
WITH monthly_transaction_counts AS (
    SELECT
        sa.owner_id,
        DATE_FORMAT(sa.transaction_date, '%Y-%m') AS txn_month, -- Extract year-month for grouping
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount sa
    WHERE sa.transaction_status IN ('Completed', 'Success')  -- Include only valid/confirmed transactions
      AND sa.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)  -- Last 12 months
    GROUP BY sa.owner_id, txn_month
),

-- Step 2: Compute each customer's average monthly transaction count
customer_avg_transactions AS (
    SELECT
        mtc.owner_id,
        AVG(mtc.monthly_txn_count) AS avg_txns_per_month  -- Average across months
    FROM monthly_transaction_counts mtc
    GROUP BY mtc.owner_id
),

-- Step 3: Categorize customers into frequency tiers (parameterized thresholds)
categorized_customers AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
        cat.avg_txns_per_month,
        CASE
            WHEN cat.avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN cat.avg_txns_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_avg_transactions cat
    JOIN users_customuser u ON u.id = cat.owner_id  -- Join to get customer names
)

-- Final Step: Summarize the categories and show insights
SELECT
    frequency_category,
    COUNT(*) AS customer_count,  -- Number of customers in each category
    ROUND(AVG(avg_txns_per_month), 2) AS avg_transactions_per_month  -- Average activity per group
FROM categorized_customers
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');  -- Custom sort order
