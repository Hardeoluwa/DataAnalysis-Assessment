-- Identify inactive savings plans with no transaction in the last 365 days

-- Step 1: Create a CTE to get the most recent successful transaction date per plan and customer
WITH last_activity AS (
    SELECT 
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_activity_date  -- Most recent successful transaction
    FROM 
        savings_savingsaccount
    WHERE 
        transaction_status = 'success'
    GROUP BY 
        plan_id, owner_id
)

-- Step 2: Use the CTE to get inactivity details per savings plan
SELECT 
    s.plan_id,
    s.owner_id,
    'Savings' AS type,  -- Static label indicating account type
    la.last_activity_date AS last_transaction_date,
    DATEDIFF(CURRENT_DATE(), la.last_activity_date) AS inactivity_days
FROM 
    savings_savingsaccount s
JOIN 
    last_activity la 
    ON s.plan_id = la.plan_id AND s.owner_id = la.owner_id
WHERE 
    s.plan_id IS NOT NULL  -- Ignore null plans
    AND DATEDIFF(CURRENT_DATE(), la.last_activity_date) > 365  -- Inactive over a year
GROUP BY 
    s.plan_id, s.owner_id, la.last_activity_date
ORDER BY 
    inactivity_days DESC

