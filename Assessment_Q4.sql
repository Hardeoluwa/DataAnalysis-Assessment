-- Q4: Customer Lifetime Value (CLV) Estimation
WITH txn_summary AS (
    -- Compute total transaction count and value for each customer
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        u.date_joined,
        COUNT(sa.id) AS total_transactions,
        COALESCE(SUM(sa.amount), 0) AS total_transaction_value,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount sa ON sa.owner_id = u.id
    GROUP BY u.id, name, u.date_joined
),
clv_calc AS (
    -- Estimate CLV: (total_txns / tenure) * 12 * profit_per_txn
    SELECT
        customer_id,
        name,
        tenure_months,
        total_transactions,
        ROUND(
            (total_transactions / NULLIF(tenure_months, 0)) * 12 * 0.001,
            2
        ) AS estimated_clv
    FROM txn_summary
)
-- Final result ordered by highest CLV
SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;
