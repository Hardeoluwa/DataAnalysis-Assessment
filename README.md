
# DataAnalytics-Assessment

This repository contains SQL solutions to the SQL Proficiency Assessment designed to evaluate technical SQL skills and problem-solving capabilities.

## Per-Question Explanations

### Question 1: High-Value Customers with Multiple Products
**Task**:  Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
**Objective**: Identify customers who have both funded savings and investment plans and sort them by total deposits.
**Approach**:
-> Joined `users_customuser` with `savings_savingsaccount` and `plans_plan` tables.
-> Used filtering criteria `is_regular_savings = 1` for savings and `is_a_fund = 1` for investment.
-> Summed `confirmed_amount` to compute total deposits (converted from kobo to naira).
-> Grouped by customer and used conditional aggregation to count savings and investments(ordered by total deposits).

## Challenges Encountered for Q1

- **Currency Handling**: Amounts were stored in kobo so therefore it required conversion to naira for accurate financial reporting. 
Also distinguishing between a savings plan and an investment plan wasn't immediately obvious.  
**Resolution:** By checking `is_regular_savings = 1` for savings and `is_a_fund = 1` for investment, I ensured accurate filtering. Also, aggregating deposits correctly in Kobo required careful type conversion to Naira for readability. Divided all `confirmed_amount` values by 100 to convert kobo to naira.

### Question 2: Transaction Frequency Analysis
**Task**:  Calculate the average number of transactions per customer per month and categorize them:
"High Frequency" (≥10 transactions/month)
"Medium Frequency" (3-9 transactions/month)
"Low Frequency" (≤2 transactions/month)
**Objective**: Classify customers based on average monthly transactions.
**Approach**:
-> Extracted month and year from transaction date for grouping.
-> Calculated total transactions per customer and determined their active months based on earliest and latest transaction dates.Counted transactions per customer per month.
-> Computed average monthly transactions using `DATEDIFF` and conditional logic.
-> Used `CASE` statement to assign frequency categories (High (≥10), Medium (3–9), or Low (≤2) ) and aggregated results to count customers per category.
-> Used Common Table Expressions (CTEs) for cleaner calculations
 

## Challenges Encountered for Q2 
**Inconsistent Date Ranges**: Differences in transaction date formats and the need to align the calculation of months for accurate averaging.
**Resolution** : Used SQL date functions like `DATEDIFF` and `TIMESTAMPDIFF(MONTH, ..., CURRENT_DATE)` to maintain consistency.
**Challenge:** Accurately deriving monthly averages from transaction dates posed a logic hurdle.  
**Resolution:** I extracted month-level grouping from the transaction timestamp and used COUNT + DISTINCT month combinations to derive monthly transaction frequency, then wrapped the logic into a CASE WHEN to categorize users intuitively.
  
### Question 3: Account Inactivity Alert
**Task**:  Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) . 
**Objective**: Identify active accounts with no transactions in the last year.
**Approach**:
-> Selected latest transaction date for each account from both savings and plans (i.e for each account)
-> Used `DATEDIFF` to calculate inactivity period relative to the current date.
-> Filtered for accounts with more than 365 days of inactivity and formatted output accordingly.
-> Filtered those where last transaction date is more than 365 days old using `CURRENT_DATE - INTERVAL '365 days'`.
-> Combined both savings and investment accounts using `UNION ALL`.
-> Calculated days since last transaction using `DATE_PART`.

## Challenges Encountered for Q3
**Challenge:** Ensuring I captured "active" accounts without transactions in exactly the last 365 days — not all-time inactivity.  
**Resolution:** I compared each account’s last transaction date against `CURRENT_DATE - INTERVAL '365 days'` and combined both savings and investment records using UNION ALL, preserving type labels and last activity dates.


### Question 4: Customer Lifetime Value (CLV) Estimation
**Task**:  For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
Account tenure (months since signup)
Total transactions
Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
Order by estimated CLV from highest to lowest
**Objective**: Estimate CLV using tenure and transaction volume.
**Approach**:
Calculated account tenure by calculating the number of months since signup.
Aggregated total confirmed transactions for each customer.
Applied the formula: `CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction`.
Sorted customers by estimated CLV in descending order.
Used 0.1% profit assumption

## Challenges Encountered for Q4
**Challenge:** Modeling the CLV with minimal assumptions and computing tenure in months with accuracy.  
**Resolution:** Used date_diff in months from signup to current date for tenure, totalled confirmed deposits as a proxy for transactions, and applied the simplified CLV formula. Finally, formatted profit correctly after converting from Kobo to Naira.


## Challenges Encountered and Resolutions

**Challenge (Data Overlap)**: Handling customers who might appear in both savings and investment tables required careful joining and aggregation.
**Resolution**: Used `LEFT JOIN` and `GROUP BY` to correctly associate and aggregate values per customer.

**Challenge**: Handling cases where customers might have multiple plans of the same type.
**Resolution**:  
Used conditional aggregation (`SUM(CASE WHEN...)`) and `GROUP BY` on `owner_id` to count only valid plan types per customer. It’s like counting different toppings on your pizza order—you don’t want the same topping listed twice just because it’s on multiple slices.

 
**Challenge**: Avoiding division by zero for new customers.
**Resolution**:  
Used `NULLIF` and filtered out customers with less than a month of tenure to ensure accurate monthly averages. It’s like calculating someone’s monthly expenses—you skip the estimate if they moved in yesterday.



**Challenge**: Distinguishing between truly inactive vs new accounts.
**Resolution**:  
Added logic to check account age and filter out recently opened accounts. It's like checking in on a friend—you don’t panic if they just moved to a new city last week, but silence from an old friend may be worth a ping.


**Challenge**: Handling edge cases with very new customers.
**Resolution**: Used `GREATEST(tenure_months, 1)` to avoid division by zero or unrealistic CLV values. It’s like adjusting your GPA—it wouldn't be fair to call someone a genius after one perfect test.



