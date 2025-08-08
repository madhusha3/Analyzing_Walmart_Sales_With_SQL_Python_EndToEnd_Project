SELECT 	* FROM walmart
select count(*) from walmart

⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️

-- 1. Analyze Payment Methods and Sales
-- Question: What are the different payment methods, and how many transactions and items were sold with each method?
-- Purpose: This helps understand customer preferences for payment methods, aiding in payment optimization strategies.
SELECT 
	payment_method,
	COUNT(*) AS Total_Transactions,
	SUM(quantity) AS Total_Items_Sold
FROM walmart
GROUP BY payment_method
ORDER BY Total_Items_Sold DESC, Total_Transactions DESC

⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️

 -- 2. Identify the Highest-Rated Category in Each Branch
 -- ● Question: Which category received the highest average rating in each branch?
 -- ● Purpose: This allows Walmart to recognize and promote popular categories in specific
 -- branches, enhancing customer satisfaction and branch-specific marketing.

 -- Approach: 1:Think in layers — first get averages
SELECT
	category, branch,
	AVG(rating) AS highest_avg_rating
FROM walmart 
GROUP BY category, branch
-- Store this as a subquery (or a CTE — Common Table Expression).

-- Step 2: From Step 1, find the highest average rating per branch
-- Think: "For each branch, give me the row where avg_rating is highest."
-- Using a CTE with ROW_NUMBER()

1HR 02MIN 13 SEC
⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️⏭️
SELECT 	* FROM walmart

-- 3. Determine the Busiest Day for Each Branch
--  ● Question: What is the busiest day of the week for each branch based on transaction
--  volume?
SELECT day_name, SUM(unit_price * quantity) OVER(PARTITION BY BRANCH order b)
--  ● Purpose: This insight helps in optimizing staffing and inventory management to
--  accommodate peak days.

-- First we need to convert "date" Column which is in text dataType to "Date" dataType
SELECT 
	date,
	TO_DATE(date, 'DD/MM/YY') AS formatted_Date
FROM walmart

ALTER TABLE walmart ADD COLUMN formatted_Date DATE;
UPDATE walmart SET formatted_Date = TO_DATE(date, 'DD/MM/YY');

ALTER TABLE walmart ADD COLUMN day_name TEXT;
UPDATE walmart SET day_name = TO_CHAR(formatted_date, 'Day')

SELECT 	* FROM walmart
--Transaction Volume is SUM of the product of unit_price and quantity --> SUM(unit_price * quantity)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'walmart';

-- super easy solution assuming Transaction Volume as Count of Invoice_id as its unique
WITH counts AS(
SELECT 
	day_name, branch,
	COUNT(invoice_id) as transaction_count
FROM walmart
GROUP BY day_name, branch
),
ranked AS(
SELECT
	day_name, branch,transaction_count,
	RANK() OVER(PARTITION BY branch ORDER BY transaction_count DESC) rnk
FROM counts)

SELECT branch, day_name, transaction_count
FROM ranked
WHERE rnk = 1

--super easy solution assuming Transaction Volume as SUM(unit_price * quantity)
WITH counts AS (
    SELECT branch, day_name, SUM(CAST(REPLACE(unit_price, '$', '') AS DOUBLE PRECISION) * quantity) AS transaction_volume
    FROM walmart
    GROUP BY branch, day_name
),

ranked AS (
SELECT 
	branch, day_name, transaction_volume,
	RANK() OVER(PARTITION BY branch ORDER BY transaction_volume DESC) rnk
FROM counts
)

SELECT branch, day_name, transaction_volume
FROM ranked
WHERE rnk = 1

-- Q4. Calculate the total quantity of items sold per payment method. List payment_method and total _ quantity.
SELECT 	* FROM walmart

SELECT SUM(quantity) AS Total_Quantity, payment_method
FROM walmart
GROUP BY payment_method

-- Q5: Determine the average, minimum, and maximum rating Of products for each city.
-- List the city, average _ rating, min_rating, and max_rating.
SELECT 	* FROM walmart
SELECT
	city,
	category,
	AVG(rating) AS avgerage_rating,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit for each category by considering total _ profit as
-- (unit _ price * quantity * profit _ margin).
-- List category and total _ profit, Ordered from highest to lowest profit.
SELECT 	* FROM walmart

SELECT 
	category,
	SUM(CAST(REPLACE(unit_price, '$', '') AS DOUBLE PRECISION) * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC

-- Q7: Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method.
SELECT 	* FROM walmart
--count the occurances of different payment methods
WITH payment_counts AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS payment_count
    FROM walmart
    GROUP BY branch, payment_method
),
ranked AS (
    SELECT 
        branch,
        payment_method,
        RANK() OVER (PARTITION BY branch ORDER BY payment_count DESC) AS rnk
    FROM payment_counts
)
SELECT 
    branch,
    payment_method AS preferred_payment_method
FROM ranked
WHERE rnk = 1;

-- Q8: Categorize sales into 3 group MORNING, AFTERNOON, EVENING Find out each of the shift and number of invoices
SELECT 	* FROM walmart

--converting time in text to time data type
SELECT
	time::time
FROM walmart

Approach 1: 
SELECT 
	CASE
		WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM time::time) < 18 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
	COUNT(invoice_id) AS invoice_count
FROM walmart
GROUP BY shift

Appraoch 2: 
SELECT
	CASE
		WHEN CAST(SUBSTRING(time,1,2) AS INTEGER) < 12 THEN 'Morning'
		WHEN CAST(SUBSTRING(time,1,2) AS INTEGER) < 18 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
	COUNT(invoice_id) AS invoice_count
FROM walmart
GROUP BY shift

-- #9 Identify 5 branch with highest decrease ratio in revevenue compare to last year 
--(current year 2023 and last year 2022)
SELECT 	* FROM walmart

WITH rev_2022 AS (
    -- Revenue for 2022 per branch
    SELECT 
        branch, 
        SUM(CAST(REPLACE(unit_price, '$', '') AS DOUBLE PRECISION) * quantity) AS revenue_2022
    FROM walmart
    WHERE EXTRACT(YEAR FROM formatted_date) = 2022
    GROUP BY branch
),
rev_2023 AS (
    -- Revenue for 2023 per branch
    SELECT 
        branch, 
        SUM(CAST(REPLACE(unit_price, '$', '') AS DOUBLE PRECISION) * quantity) AS revenue_2023
    FROM walmart
    WHERE EXTRACT(YEAR FROM formatted_date) = 2023
    GROUP BY branch
),
combined AS (
    -- Combine 2022 and 2023 revenues, calculate decrease ratio
    SELECT 
        COALESCE(r22.branch, r23.branch) AS branch,
        COALESCE(r22.revenue_2022, 0) AS revenue_2022,
        COALESCE(r23.revenue_2023, 0) AS revenue_2023,
        CASE 
            WHEN COALESCE(r22.revenue_2022, 0) = 0 THEN NULL
            ELSE (r22.revenue_2022 - r23.revenue_2023) / r22.revenue_2022
        END AS decrease_ratio
    FROM rev_2022 r22
    FULL OUTER JOIN rev_2023 r23 ON r22.branch = r23.branch
)
-- Get top 5 branches with highest decrease ratio
SELECT 
    branch, 
    revenue_2022, 
    revenue_2023, 
    decrease_ratio
FROM combined
WHERE decrease_ratio IS NOT NULL AND decrease_ratio > 0
ORDER BY decrease_ratio DESC
LIMIT 5;
