CREATE DATABASE IF NOT EXISTS DATA_ANALYSIS;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------- FEATURE ENGINEERING ------------------------------------------------------------

-- --------------------------------------------------------------- time_of_day ----------------------------------------------------------------

SELECT
	time,
	(CASE 
		WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
		WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
		ELSE 'Evening'
	END) AS time_of_date
FROM sales;

ALTER TABLE SALES ADD COLUMN time_of_day varchar(20);

UPDATE SALES
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
		WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
		ELSE 'Evening'
	END
);

-- --------------------------------------------------------------- day_name ----------------------------------------------------------------


SELECT
	date,
    dayname(DATE) AS day_name
FROM SALES;

ALTER TABLE SALES ADD COLUMN day_name VARCHAR(10);

UPDATE SALES
SET day_name = DAYNAME(DATE);

-- --------------------------------------------------------------- month_name ----------------------------------------------------------------

SELECT
	date,
    monthname(date) AS month_name
FROM SALES;

ALTER TABLE SALES ADD COLUMN month_name VARCHAR(10);

UPDATE SALES
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------- Exploratory Data Analysis (EDA) ------------------------------------------------------

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------- Generic --------------------------------------------------------------------


-- 1. How many unique cities does the data have?

SELECT 
	DISTINCT city 
FROM sales;

-- 2. In which city is each branch?

SELECT 
	DISTINCT branch 
FROM sales;


SELECT 
	DISTINCT city, branch
FROM sales;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------- Product -------------------------------------------------------------------

-- 1. How many unique product lines does the data have?

SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

-- 2. What is the most common payment method?

SELECT
	payment,
	COUNT(payment) AS cnt
FROM sales
GROUP BY payment
ORDER BY cnt DESC;

-- 3. What is the most selling product line?

SELECT 
	product_line,
    COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- 4. What is the total revenue by month?

SELECT 
DISTINCT MONTH_NAME
FROM SALES;

SELECT
	month_name AS Month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS?

SELECT
	month_name AS Month,
    COUNT(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- 6. What product line had the largest revenue?

SELECT
	product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 7. What is the city with the largest revenue?

SELECT
	city,
	branch,
    SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- 8. What product line had the largest VAT?

SELECT
	product_line,
    AVG(tax_pct) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". 
--    Good if its greater than average sales?

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- 10. Which branch sold more products than average product sold?

SELECT
	branch,
    SUM(quantity) as qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales)
ORDER BY qty DESC;

-- 11. What is the most common product line by gender?

SELECT
	gender,
	product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- 12. What is the average rating of each product line?

SELECT
	product_line,
    ROUND(AVG(rating), 2)  AS Avg_rating
FROM sales
GROUP BY product_line
ORDER BY Avg_rating DESC;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------- Sales ----------------------------------------------------------------------

-- 1. Number of sales made in each time of the day per weekday?

SELECT
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 2. Which of the customer types brings the most revenue?

SELECT
	customer_type,
   ROUND(SUM(total)) AS total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;

-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?

SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- 4. Which customer type pays the most in VAT?

SELECT 
	customer_type,
    ROUND(AVG(tax_pct), 2) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax DESC;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------- Customer -----------------------------------------------------------------

-- 1. How many unique customer types does the data have?

SELECT 
	DISTINCT customer_type
FROM sales;

-- 2. How many unique payment methods does the data have?

SELECT 
	DISTINCT payment
FROM sales;

-- 3. What is the most common customer type?

SELECT 
	customer_type,
    COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- 4. Which customer type buys the most?

SELECT 
	customer_type,
    COUNT(*) AS cstm_cnt
FROM sales
GROUP BY customer_type
ORDER BY cstm_cnt DESC;

-- 5. What is the gender of most of the customers?

SELECT 
	gender,
    COUNT(*) AS gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 6. What is the gender distribution per branch?

SELECT 
	gender,
    COUNT(*) AS gender_cnt
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 7. Which time of the day do customers give most ratings?

SELECT 
	time_of_day,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 8. Which time of the day do customers give most ratings per branch?

SELECT 
	time_of_day,
    ROUND(AVG(rating), 2) AS avg_rating
FROM sales
WHERE branch = "C"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 9. Which day of the week has the best avg ratings?

SELECT
	day_name,
	ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- 10. Which day of the week has the best average ratings per branch?

SELECT 
	day_name,
	ROUND(AVG(rating), 2) AS  avg_rating
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------- THANK YOU FOR ALL FRIENDS !!!! --------------------------------------------------





