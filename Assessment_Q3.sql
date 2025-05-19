WITH last_activity AS (
    SELECT 
        plan_id,
        owner_id,
        MAX(transaction_date) AS last_activity_date
    FROM 
        savings_savingsaccount
    WHERE 
        transaction_status = 'success'
    GROUP BY 
        plan_id, owner_id
)

SELECT 
    s.plan_id,
    s.owner_id,
    'Savings' AS type,
    la.last_activity_date AS last_transaction_date,
    DATEDIFF(CURRENT_DATE(), la.last_activity_date) AS inactivity_days
FROM 
    savings_savingsaccount s
JOIN 
    last_activity la ON s.plan_id = la.plan_id AND s.owner_id = la.owner_id
WHERE 
    s.plan_id IS NOT NULL  -- Ensure we're only looking at savings accounts with plans
    AND DATEDIFF(CURRENT_DATE(), la.last_activity_date) > 365
GROUP BY 
    s.plan_id, s.owner_id, la.last_activity_date
ORDER BY 
    inactivity_days DESC;