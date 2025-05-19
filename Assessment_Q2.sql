

SELECT MIN(transaction_date), MAX(transaction_date)
FROM savings_savingsaccount
WHERE transaction_date IS NOT NULL;

SELECT owner_id, COUNT(*) AS total_txns, COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) AS active_months
FROM savings_savingsaccount
GROUP BY owner_id
HAVING active_months > 1;

WITH monthly_txn_counts AS (
    SELECT owner_id, DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month, COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    GROUP BY owner_id, txn_month
), customer_avg_txn AS (
    SELECT owner_id, AVG(monthly_txn_count) AS avg_txns_per_month
    FROM monthly_txn_counts
    GROUP BY owner_id
)
SELECT 
    MAX(avg_txns_per_month) AS max_avg,
    MIN(avg_txns_per_month) AS min_avg,
    AVG(avg_txns_per_month) AS overall_avg
FROM customer_avg_txn;

WITH monthly_transaction_counts AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    WHERE transaction_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
      AND transaction_status IN ('Completed', 'Success')  -- update if needed
    GROUP BY owner_id, txn_month
),
customer_avg_transactions AS (
    SELECT
        owner_id,
        AVG(monthly_txn_count) AS avg_txns_per_month
    FROM monthly_transaction_counts
    GROUP BY owner_id
),
categorized_customers AS (
    SELECT
        CASE
            WHEN avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txns_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txns_per_month
    FROM customer_avg_transactions
)
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txns_per_month), 2) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');

-- Step 1: Compute number of transactions per customer per month
WITH monthly_transaction_counts AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM savings_savingsaccount
    WHERE transaction_status IN ('Completed', 'Success')  -- adjust if needed
      AND transaction_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY owner_id, txn_month
),

-- Step 2: Compute average monthly transactions per customer
customer_avg_transactions AS (
    SELECT
        owner_id,
        AVG(monthly_txn_count) AS avg_txns_per_month
    FROM monthly_transaction_counts
    GROUP BY owner_id
),

-- Step 3: Categorize customers by frequency
categorized_customers AS (
    SELECT
        CASE
            WHEN avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txns_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txns_per_month
    FROM customer_avg_transactions
)

-- Final Output: Group and summarize by frequency category
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txns_per_month), 2) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');



