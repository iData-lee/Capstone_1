/*
===========================================================
Project: Capstone 1 - EmporiUm Maryland (Northeast Region) Analysis
Author: Idasha Lee
DATE: 11/02/2026
DATABASE: sample_sales
Territory: Maryland (MD) Northeast Region - In store
======================================================================
*/
USE sample_sales;
SHOW TABLES; 
DESCRIBE management;
SELECT * FROM management 
LIMIT 10; 
SELECT state, region 
FROM management;
-- Above is how I discovered the region for Maryland. The region is Northeast. 
-- ===========================================================================
-- Sales Manager of the MD sales department wants to know:
/* Q1 Total Revenue overall for sales in MD. Start and End Date that tells the period 
 of data coverage.  
 ANSWER: 
 TOTAL REVENUE: '11451615.09' START DATE: 2022-01-01 END DATE: 2025-12-31
*/ 
SELECT SUM(ss.sale_amount) AS total_revenue,
	   MIN(ss.Transaction_Date) AS start_date, 
       MAX(ss.transaction_date) AS end_date
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid
WHERE state = 'Maryland'; 
-- ANSWER: TOTAL REVENUE - '11451615.09' START DATE: 2022-01-01 END DATE: 2025-12-31 
DESCRIBE store_sales; 
/* To find the date type which is Transaction_Date I described store sales and completed Q1 by adding the min and max
within the syntax for Q1. */ 
-- Q2. Revenue breakdown by year and month for sales in Maryland
SELECT YEAR(ss.transaction_date) AS sales_year,
       MONTH(ss.transaction_date) AS sales_month,
       SUM(ss.sale_amount)        AS total_revenue
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid
WHERE sl.state = 'Maryland' 
GROUP BY sales_year, sales_month
ORDER BY sales_year, sales_month;  
-- ANSWER: created csv file of data
-- Q3. Comparison of Total Revenue for MD and the Northeast Region  
SELECT SUM(ss.sale_amount)   AS region_revenue
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid 
JOIN management m ON sl.state = m.state 
WHERE m.region = 'Northeast';
-- Answer: Total Revenue For Northeast Region: '24237526.98' 
-- 	Q4. Number of transactions per month. Average transaction amount by product category for MD Sales.
SELECT YEAR(ss.transaction_date)   AS sales_year,
	   MONTH(ss.transaction_date)  AS sales_month, 
       i.category                  AS category,
       COUNT(*)                   AS num_transactions, 
       AVG(ss.sale_amount)       AS avg_transaction
FROM store_sales ss 
JOIN store_locations sl ON ss.store_id = sl.storeid
JOIN products p ON ss.prod_num = p.prodnum 
JOIN inventory_categories i ON p.categoryid = i.categoryid
WHERE sl.state = 'Maryland'
GROUP BY sales_month, sales_year, category
Order by sales_year, sales_month, category; 
-- ANSWER: saved as csv file
-- Q5 Provide a Ranking of in store sales performance by each store in MD.
SELECT * FROM store_locations WHERE state = 'Maryland';
# Maryland is an in-store territory so stores are ranked. 
SELECT sl.storelocation, 
       SUM(ss.sale_amount)         AS total_revenue,
       RANK() OVER (ORDER BY SUM(ss.sale_amount) DESC) AS sales_rank
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid
WHERE sl.state = 'Maryland'
GROUP BY sl.storelocation, sl.storeid
ORDER BY total_revenue DESC;
-- Q6 Reccomendation for where to focus sales attention in the next quarter. 
-- ================ RECOMMENDATION ==================================
#
