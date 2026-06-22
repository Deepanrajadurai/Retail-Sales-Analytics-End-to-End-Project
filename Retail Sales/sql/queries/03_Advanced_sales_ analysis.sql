use ecommers ;

select * from sales_clean ;

-- Advanced SQL Analytics Questions

-- MODULE 1 : Running Totals

-- Q1. What is the cumulative monthly sales?
WITH monthly_sales AS (	
			SELECT  YEAR(order_date) AS year ,
		    DATE_FORMAT(order_date, '%Y-%m') AS month ,
            SUM(total_price) AS monthly_sales
            FROM vw_sales
            GROUP BY  year , month 
) 
SELECT 
	year , month , monthly_sales ,
    SUM(monthly_sales) OVER(ORDER BY year , month )  AS cumulative_monthly_sales
 FROM monthly_sales 
 ORDER BY year , month ;
 
-- Q2. What is the cumulative monthly profit?
WITH monthly_profit AS (	
			SELECT  YEAR(order_date) AS year ,
		    DATE_FORMAT(order_date, '%Y-%m') AS month ,
            SUM(total_price - total_cost) AS monthly_profit
            FROM vw_sales
            GROUP BY  year , month 
) 
SELECT 
	year , month , monthly_profit ,
    SUM(monthly_profit) OVER(ORDER BY year , month )  AS cumulative_monthly_profit
 FROM monthly_profit 
 ORDER BY year , month ;
 
-- Q3. What is the cumulative quarterly revenue?
WITH quarterly_sales AS (	
			SELECT  YEAR(order_date) AS year ,
		    QUARTER(order_date) AS quarter_no ,
            SUM(total_price) AS quarterly_sales
            FROM vw_sales
            GROUP BY  year , quarter_no
) 
SELECT 
	year , quarter_no , quarterly_sales ,
    SUM(quarterly_sales) OVER(ORDER BY year , quarter_no )  AS cumulative_quarterly_sales
 FROM quarterly_sales 
 ORDER BY year , quarter_no ;
 
-- Q4. What is the cumulative yearly revenue?
WITH yearly_sales AS (	
			SELECT  YEAR(order_date) AS year ,
            SUM(total_price) AS yearly_sales
            FROM vw_sales
            GROUP BY  year 
) 
SELECT 
	year  , yearly_sales ,
    SUM(yearly_sales) OVER(ORDER BY year )  AS cumulative_yearly_sales
 FROM yearly_sales 
 ORDER BY year ;

-- MODULE 2 : Previous / Next Period Analysis 
-- Q5. What were the previous month's sales? 
WITH monthly_sales AS (
	SELECT
	YEAR(order_date) AS year  ,
    DATE_FORMAT(order_date , '%Y-%m') AS month ,
    SUM(total_price) AS monthly_sales 
FROM vw_sales 
GROUP BY year , month 
) 
SELECT year , month , monthly_sales ,
		LAG(monthly_sales) OVER(ORDER BY  year) AS previous_month_sales
FROM monthly_sales 
ORDER BY  year  ;

-- Q6. What were the previous quarter's sales?
WITH quarter_sales AS (
	SELECT
	YEAR(order_date) AS year  ,
    QUARTER(order_date ) AS quarter_no ,
    SUM(total_price) AS quarter_sales 
FROM vw_sales 
GROUP BY year , quarter_no 
) 
SELECT year , quarter_no , quarter_sales ,
		LAG(quarter_sales) OVER(ORDER BY  year , quarter_no) AS previous_quarter_sales
FROM quarter_sales 
ORDER BY  year , quarter_no ;

-- Q7. What were the previous year's sales? 
WITH yearly_sales AS (
	SELECT
	YEAR(order_date) AS year  ,
    SUM(total_price) AS yearly_sales 
FROM vw_sales 
GROUP BY year  
) 
SELECT year , yearly_sales ,
		LAG(yearly_sales) OVER(ORDER BY  year ) AS previous_year_sales
FROM yearly_sales 
ORDER BY  year ;

-- Q8. What are the next month's sales? 
WITH monthly_sales AS (
	SELECT
	YEAR(order_date) AS year  ,
    DATE_FORMAT(order_date , '%Y-%m') AS month ,
    SUM(total_price) AS monthly_sales 
FROM vw_sales 
GROUP BY year , month 
) 
SELECT year , month , monthly_sales ,
		LEAD(monthly_sales) OVER(ORDER BY  year , month) AS next_month_sales
FROM monthly_sales 
ORDER BY  year , month ;

-- Q9. Compare current month sales with next month sales.
WITH monthly_sales AS (
	SELECT
	YEAR(order_date) AS year  ,
    DATE_FORMAT(order_date , '%Y-%m') AS month ,
    SUM(total_price) AS monthly_sales 
FROM vw_sales 
GROUP BY year , month 
) 
SELECT year , month , monthly_sales AS current_month_sales ,
        LEAD(monthly_sales) OVER(ORDER BY  year , month) AS next_month_sales
FROM monthly_sales 
ORDER BY  year , month ;

-- -- Q10. Compare current month sales with next month sales and Previous month sales.
WITH monthly_sales AS (
	SELECT
	YEAR(order_date) AS year  ,
    DATE_FORMAT(order_date , '%Y-%m') AS month ,
    SUM(total_price) AS monthly_sales 
FROM vw_sales 
GROUP BY year , month 
) 
SELECT year, month,
    LAG(monthly_sales) OVER(ORDER BY month) AS previous_month_sales,
    monthly_sales AS current_month_sales,
    LEAD(monthly_sales) OVER(ORDER BY month) AS next_month_sales
FROM monthly_sales;

-- MODULE 3 : Growth Analysis
-- Q10. Month-over-Month (MoM) Sales Growth
WITH Monthly_sales AS (
SELECT 
	YEAR(order_date) AS year , DATE_FORMAT(order_date ,   '%Y-%m') AS Month ,
    SUM(total_price) AS Monthly_sales 
FROM vw_sales 
GROUP BY YEAR(order_date), DATE_FORMAT(order_date, '%Y-%m')
) ,  Sales_Growth AS (
			SELECT * , LAG(Monthly_sales) OVER( ORDER BY year , Month )    AS previous_month_sales
FROM Monthly_sales
) SELECT year , Month , Monthly_sales , 
	ROUND( (Monthly_sales -  previous_month_sales) * 100.0 / NULLIF(previous_month_sales, 0), 2) AS MoM_Sales_Growth 
FROM Sales_Growth 
ORDER BY year, Month ;

-- Q11. Quarter-over-Quarter (QoQ) Sales Growth
WITH Quarter_sales AS (
SELECT 
	YEAR(order_date) AS year ,
	QUARTER(order_date) AS Quarter_no ,
    SUM(total_price) AS Quarter_sales 
FROM vw_sales 
GROUP BY
    YEAR(order_date), QUARTER(order_date)
) , 
Sales_Growth AS (
			SELECT * , 
					LAG(Quarter_sales) OVER( ORDER BY year , Quarter_no )    AS previous_Quarter_sales
FROM Quarter_sales
) 
SELECT year , Quarter_no , Quarter_sales , 
	ROUND( 
			(Quarter_sales -  previous_Quarter_sales) * 100.0 /
			NULLIF(previous_Quarter_sales, 0),
        2) AS QoQ_Sales_Growth 
FROM Sales_Growth 
ORDER BY year, Quarter_no ;


-- Q12. Year-over-Year (YoY) Sales Growth
WITH yearly_sales AS (
SELECT 
	YEAR(order_date) AS year ,
    SUM(total_price) AS yearly_sales 
FROM vw_sales 
GROUP BY YEAR(order_date)
) , 
Sales_Growth AS (
			SELECT * , 
					LAG(yearly_sales) OVER( ORDER BY year  )    AS previous_year_sales
FROM yearly_sales
) 
SELECT year , yearly_sales , 
	ROUND( 
			(yearly_sales -  previous_year_sales) * 100.0 /
			NULLIF(previous_year_sales, 0),
        2) AS YoY_Sales_Growth 
FROM Sales_Growth 
ORDER BY year ;


SELECT * FROM  sales_clean ;
-- SELECT * FROM customers WHERE GROUP BY ORDER BY LIMIT  WITH LAG LEAD
-- DESC ASCE  JOIN ON UPDATE ALTER SET  WHEN THEN AVG HAVING MONTH
-- Q13. Monthly Revenue Difference
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS year,
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_price) AS monthly_revenue
    FROM vw_sales
    GROUP BY
        YEAR(order_date),
        DATE_FORMAT(order_date, '%Y-%m')
),
revenue_difference AS (
    SELECT
        *,
        LAG(monthly_revenue) OVER(
            ORDER BY year, month
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    year,
    month,
    monthly_revenue,
    previous_month_revenue,
    monthly_revenue - previous_month_revenue AS revenue_difference
FROM revenue_difference
ORDER BY year, month;

-- Q14. Quarterly Revenue Difference
WITH quarterly_revenue AS (
    SELECT
        YEAR(order_date) AS year,
        QUARTER(order_date) AS quarter_no,
        SUM(total_price) AS quarterly_revenue
    FROM vw_sales
    GROUP BY
        YEAR(order_date), QUARTER(order_date)
),
revenue_difference AS (
    SELECT
        *,
        LAG(quarterly_revenue) OVER(
            ORDER BY year, quarter_no
        ) AS previous_quarter_revenue
    FROM quarterly_revenue
)
SELECT
    year,
    quarter_no,
    quarterly_revenue,
    previous_quarter_revenue,
    quarterly_revenue - previous_quarter_revenue AS revenue_difference
FROM revenue_difference
ORDER BY year, quarter_no;

/* MODULE 4 : Rolling / Moving Average */
-- Q15. Rolling 3-Month Average Sales
WITH month_Sales AS (
	SELECT YEAR(order_date) AS year ,
			DATE_FORMAT(order_date , '%Y-%m') AS  MONTH ,
            SUM( total_price) AS month_Sales
	FROM vw_sales 
    GROUP BY YEAR(order_date)  ,DATE_FORMAT(order_date , '%Y-%m')
)
SELECT year , MONTH , ROUND(month_Sales,2) AS month_Sales ,
		ROUND( AVG(month_Sales) OVER(ORDER BY year , Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW )  ,
            2) AS 3_month_avg_Sales
FROM month_Sales 
ORDER BY  year , Month ;

-- Q16. Rolling 6-Month Average Sales
WITH month_Sales AS (
	SELECT YEAR(order_date) AS year ,
			DATE_FORMAT(order_date , '%Y-%m') AS  MONTH ,
            SUM( total_price) AS month_Sales
	FROM vw_sales 
    GROUP BY YEAR(order_date)  ,
			DATE_FORMAT(order_date , '%Y-%m')
)
SELECT year , MONTH , ROUND(month_Sales,2) AS month_Sales ,
		ROUND(
			AVG(month_Sales) 
            OVER(ORDER BY year , Month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW )  ,
            2) AS 6_month_avg_Sales
FROM month_Sales 
ORDER BY  year , Month ;
-- Q17. Rolling 12-Month Average Sales
WITH month_Sales AS (
	SELECT YEAR(order_date) AS year ,
			DATE_FORMAT(order_date , '%Y-%m') AS  MONTH ,
            SUM( total_price) AS month_Sales
	FROM vw_sales 
    GROUP BY YEAR(order_date)  ,
			DATE_FORMAT(order_date , '%Y-%m')
)
SELECT year , MONTH , ROUND(month_Sales,2) AS month_Sales ,
		ROUND(
			AVG(month_Sales) 
            OVER(ORDER BY year , Month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW )  ,
            2) AS 12_month_avg_Sales
FROM month_Sales 
ORDER BY  year , Month ;

/* MODULE 5 : Ranking */
-- Q18. Rank Months by Revenue

WITH monthly_revenue AS
(
    SELECT
        YEAR(order_date) AS year,
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_price) AS monthly_revenue
    FROM vw_sales
    GROUP BY
        YEAR(order_date),
        DATE_FORMAT(order_date, '%Y-%m')
)
SELECT  year, month,monthly_revenue,
    RANK() OVER(
        ORDER BY monthly_revenue DESC
    ) AS rank_by_monthly_revenue
FROM monthly_revenue
ORDER BY rank_by_monthly_revenue;

-- Q19. Dense Rank Months by Revenue 
WITH monthly_revenue AS
(
    SELECT
        YEAR(order_date) AS year,
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_price) AS monthly_revenue
    FROM vw_sales
    GROUP BY
        YEAR(order_date),
        DATE_FORMAT(order_date, '%Y-%m')
)

SELECT year, month,monthly_revenue,
    DENSE_RANK() OVER(
        ORDER BY monthly_revenue DESC
    ) AS rank_by_monthly_revenue
FROM monthly_revenue
ORDER BY rank_by_monthly_revenue;

-- Q20. Rank Products by Revenue
WITH revenue AS
(
    SELECT
         product_name ,
        SUM(total_price) AS revenue
    FROM vw_sales
    GROUP BY product_name
)
SELECT
	product_name ,
    revenue,
    RANK() OVER( ORDER BY revenue DESC) AS rank_by_product_revenue
FROM revenue
ORDER BY rank_by_product_revenue;

-- Q21. Top Selling Product in Every Month 
WITH revenue AS
(
    SELECT
		DATE_FORMAT(order_date, '%Y-%m') AS month,
         product_name ,
        SUM(total_price) AS revenue
    FROM vw_sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m') , product_name
),
month_by_rnk AS (
SELECT *,
    RANK() OVER( PARTITION BY month ORDER BY  revenue  DESC) AS rnk
FROM revenue
) SELECT month, product_name,
		revenue, rnk 
FROM month_by_rnk 
WHERE rnk =1 
ORDER BY month , revenue  DESC ;

-- Q22. Top Customer in Every Year
WITH customer_yearly_revenue AS
(
    SELECT
		YEAR(order_date) AS year,
         customer_id , customer_name , 
        SUM(total_price) AS customer_yearly_revenue
    FROM sales_clean
    GROUP BY YEAR(order_date) , customer_id , customer_name
),
customer_rank AS (
SELECT *,
    RANK() OVER( PARTITION BY year ORDER BY  customer_yearly_revenue  DESC) AS rnk
FROM customer_yearly_revenue
) SELECT year, customer_id  AS top_customer , customer_name ,
		customer_yearly_revenue, rnk 
FROM customer_rank 
WHERE rnk =1 
ORDER BY year , customer_yearly_revenue  DESC ;

SELECT * FROM  vw_sales ;
-- SELECT * FROM customers WHERE GROUP BY ORDER BY LIMIT  WITH LAG LEAD
-- DESC ASCE  JOIN ON UPDATE ALTER SET  WHEN THEN AVG HAVING MONTH

-- Q23 What is the highest monthly revenue in each year?
WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS year,
        DATE_FORMAT(order_date,'%Y-%m') AS month,
        SUM(total_price) AS revenue
    FROM vw_sales
    GROUP BY
        YEAR(order_date),
        DATE_FORMAT(order_date,'%Y-%m')
)
SELECT
    year, month,revenue,
    FIRST_VALUE(revenue) OVER(PARTITION BY year ORDER BY revenue DESC ) AS highest_monthly_revenue
FROM monthly_revenue;

-- Q24 Which month had the lowest revenue in each year
WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS year,
        DATE_FORMAT(order_date,'%Y-%m') AS month,
        SUM(total_price) AS revenue
    FROM vw_sales
    GROUP BY
        YEAR(order_date),
        DATE_FORMAT(order_date,'%Y-%m')
)
SELECT year, month,
    revenue,
    LAST_VALUE(revenue) OVER(
        PARTITION BY year ORDER BY revenue DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_monthly_revenue
FROM monthly_revenue;

-- Q25 Divide customers into 4 spending groups.
WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(total_price) AS revenue
    FROM vw_sales
    GROUP BY customer_id
)
SELECT customer_id, revenue,
    NTILE(4) OVER(
        ORDER BY revenue DESC
    ) AS customer_quartile
FROM customer_sales;