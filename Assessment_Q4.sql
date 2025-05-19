-- Q4: Customer Lifetime Value (CLV) Estimation
-- Objective: Calculate estimated CLV based on transaction frequency and profit per transaction

WITH txn_summary AS (
    -- Aggregate customer transaction data and tenure in months
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,      -- Full customer name
        u.date_joined,                                       -- Customer joining date
        COUNT(sa.id) AS total_transactions,                  -- Total transactions made by customer
        COALESCE(SUM(sa.amount), 0) AS total_transaction_value,  -- Total transaction value; handles NULL sums
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months -- Customer tenure in months
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount sa ON sa.owner_id = u.id      -- Left join to include customers with zero transactions
    GROUP BY 
        u.id, name, u.date_joined
),

clv_calc AS (
    -- Calculate estimated Customer Lifetime Value (CLV)
    SELECT
        customer_id,
        name,
        tenure_months,
        total_transactions,
        -- CLV estimate: average monthly transactions * 12 months * assumed profit per txn (0.001)
        ROUND(
            (total_transactions / NULLIF(tenure_months, 0)) * 12 * 0.001,
            2
        ) AS estimated_clv
    FROM 
        txn_summary
)

-- Final output sorted by descending estimated CLV
SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM 
    clv_calc
ORDER BY 
    estimated_clv DESC;
