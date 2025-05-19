SELECT
    u.id AS customer_id,
    u.first_name,
    u.last_name,
    -- Sum of savings balances
    COALESCE((
        SELECT SUM(sa.new_balance)
        FROM savings_savingsaccount sa
        WHERE sa.owner_id = u.id AND sa.new_balance > 0
    ), 0) AS total_savings_balance,
    -- Sum of investment amounts
    COALESCE((
        SELECT SUM(pp.amount)
        FROM plans_plan pp
        WHERE pp.owner_id = u.id AND pp.amount > 0
    ), 0) AS total_investment_amount,
    -- Total deposits
    COALESCE((
        SELECT SUM(sa.new_balance)
        FROM savings_savingsaccount sa
        WHERE sa.owner_id = u.id AND sa.new_balance > 0
    ), 0) + COALESCE((
        SELECT SUM(pp.amount)
        FROM plans_plan pp
        WHERE pp.owner_id = u.id AND pp.amount > 0
    ), 0) AS total_deposits
FROM users_customuser u
WHERE EXISTS (
    SELECT 1 FROM savings_savingsaccount sa WHERE sa.owner_id = u.id AND sa.new_balance > 0
)
AND EXISTS (
    SELECT 1 FROM plans_plan pp WHERE pp.owner_id = u.id AND pp.amount > 0
)
ORDER BY total_deposits DESC
LIMIT 1000;


SELECT
    u.id AS customer_id,
    u.first_name,
    u.last_name,
    COALESCE(sa_sums.total_savings_balance, 0) AS total_savings_balance,
    COALESCE(pp_sums.total_investment_amount, 0) AS total_investment_amount,
    COALESCE(sa_sums.total_savings_balance, 0) + COALESCE(pp_sums.total_investment_amount, 0) AS total_deposits
FROM
    users_customuser u
    LEFT JOIN (
        SELECT owner_id, SUM(new_balance) AS total_savings_balance
        FROM savings_savingsaccount
        WHERE new_balance > 0
        GROUP BY owner_id
    ) sa_sums ON sa_sums.owner_id = u.id
    LEFT JOIN (
        SELECT owner_id, SUM(amount) AS total_investment_amount
        FROM plans_plan
        WHERE amount > 0
        GROUP BY owner_id
    ) pp_sums ON pp_sums.owner_id = u.id
WHERE
    sa_sums.total_savings_balance IS NOT NULL
    AND pp_sums.total_investment_amount IS NOT NULL
ORDER BY
    total_deposits DESC
LIMIT 1000;


SELECT 
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COALESCE(sa_sums.total_savings_balance, 0) AS total_savings_balance,
    COALESCE(pp_sums.total_investment_amount, 0) AS total_investment_amount,
    COALESCE(sa_sums.total_savings_balance, 0) + COALESCE(pp_sums.total_investment_amount, 0) AS total_deposits
FROM users_customuser u
LEFT JOIN (
    SELECT 
        owner_id, 
        SUM(new_balance) AS total_savings_balance
    FROM savings_savingsaccount
    WHERE new_balance > 0
    GROUP BY owner_id
) sa_sums ON sa_sums.owner_id = u.id
LEFT JOIN (
    SELECT 
        owner_id, 
        SUM(amount) AS total_investment_amount
    FROM plans_plan
    WHERE amount > 0
    GROUP BY owner_id
) pp_sums ON pp_sums.owner_id = u.id
WHERE sa_sums.total_savings_balance IS NOT NULL 
  AND pp_sums.total_investment_amount IS NOT NULL
ORDER BY total_deposits DESC
LIMIT 1000;
