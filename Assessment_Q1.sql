-- Retrieve the top 1000 customers by total deposits (savings + investments)
-- Only include customers who have both a savings and an investment record with positive balances

SELECT 
    u.id AS customer_id,
    -- Concatenate first and last names for full name display
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    
    -- Total savings balance (only positive balances)
    COALESCE(sa_sums.total_savings_balance, 0) AS total_savings_balance,

    -- Total investment amount (only positive investments)
    COALESCE(pp_sums.total_investment_amount, 0) AS total_investment_amount,

    -- Total deposits (savings + investments)
    COALESCE(sa_sums.total_savings_balance, 0) + COALESCE(pp_sums.total_investment_amount, 0) AS total_deposits

FROM users_customuser u

-- Subquery: Aggregate savings per user where balance > 0
LEFT JOIN (
    SELECT 
        owner_id, 
        SUM(new_balance) AS total_savings_balance
    FROM savings_savingsaccount
    WHERE new_balance > 0
    GROUP BY owner_id
) sa_sums ON sa_sums.owner_id = u.id

-- Subquery: Aggregate investments per user where amount > 0
LEFT JOIN (
    SELECT 
        owner_id, 
        SUM(amount) AS total_investment_amount
    FROM plans_plan
    WHERE amount > 0
    GROUP BY owner_id
) pp_sums ON pp_sums.owner_id = u.id

-- Filter: Include only users who have BOTH savings and investments
WHERE sa_sums.total_savings_balance IS NOT NULL 
  AND pp_sums.total_investment_amount IS NOT NULL

-- Order by highest total deposits
ORDER BY total_deposits DESC


