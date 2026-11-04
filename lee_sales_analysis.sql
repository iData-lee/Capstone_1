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
*/ 
SELECT SUM(ss.sale_amount) AS total_revenue,
	   MIN(ss.Transaction_Date) AS start_date, 
       MAX(ss.transaction_date) AS end_date
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid
WHERE sl.state = 'Maryland'; 
-- ANSWER: TOTAL REVENUE - '11,451,615.09' START DATE: 2022-01-01 END DATE: 2025-12-31 
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
-- ANSWER: saved as csv file
-- Q3. Comparison of Total Revenue for MD and the Northeast Region  
SELECT SUM(ss.sale_amount)   AS northeast_revenue
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid 
JOIN management m ON sl.state = m.state 
WHERE m.region = 'Northeast';
-- Answer: Total Revenue For Northeast Region: '24,237,526.98' 
-- ================================================================================================
-- Troubleshooting for Q3 (Somehow the state of Maryland has a higher total revenue than the region it belongs in.)
SELECT *
FROM management
ORDER BY region; 
-- Confirmed I was using the correct region name
SELECT DISTINCT m.region AS region_value, LENGTH(m.region) AS len
FROM management m;
-- Confirmed no misspelling region values or hidden spaces
SELECT *
FROM management
WHERE state = 'Maryland';
-- Confirmed Maryland row is identical in region
SELECT m.state,
       m.region AS region,
       SUM(ss.sale_amount) AS revenue
FROM   store_sales ss
JOIN   store_locations sl ON ss.store_id = sl.storeid
JOIN   management m ON sl.state = m.state
GROUP BY m.state, m.region
ORDER BY region, m.state; 
-- Confirmed which states were in the region with MD. To discover and conclude that my sum was correct just had an error in typing out the numbers which has been resolved. 
/* ANSWER:
Maryland Revenue: 11,451,615.09
Northeast Revenue: 24,237,526.98
Maryland Share: 47.25 %
*/
SELECT maryland_revenue,
       northeast_revenue,
       ROUND(maryland_revenue / northeast_revenue * 100, 2) AS maryland_share_prcnt
FROM (
	SELECT
     (SELECT SUM(ss.sale_amount)
     FROM store_sales ss 
     JOIN store_locations sl ON ss.store_id =sl.storeid
     WHERE sl.state = 'Maryland')                              AS maryland_revenue,
     (SELECT SUM(ss.sale_amount)
     FROM store_sales ss
     JOIN store_locations sl ON ss.store_id = sl.storeid
     JOIN management m ON sl.state = m.state
     WHERE m.region = 'Northeast')                             AS northeast_revenue
     ) AS totals;
-- Created a subquery to calculate the percentage of revenue MD produces for the Northeast Region. 
# Percentage added to original ANSWER above 
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
# Collecting category perfomance without North Harford for analysis 
SELECT i.category                  AS category,
	   COUNT(*)                    AS num_trancations,
       AVG(ss.sale_amount)        AS total_revenue
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid
JOIN products p ON ss.prod_num = p.prodnum
JOIN inventory_categories i ON p.categoryid = i.categoryid
WHERE sl.state = 'Maryland'
AND sl.storelocation != 'North Harford' 
GROUP BY i.category
ORDER BY total_revenue DESC;
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
-- ANSWER: saved as csv file
-- =============================================================================
# Quick troubleshooting and run check on the North Hartford location due to its unusal revenue amount.
SELECT *
FROM store_locations
WHERE storelocation = 'North Harford';
-- Was provided with store name, location and store id but no reason on the revenue. Will check sales. 
SELECT sl.storelocation,
       COUNT(*)                   AS num_transactions,
       AVG(ss.sale_amount)        AS avg_sale,
       SUM(ss.sale_amount)        AS total_revenue
FROM store_sales ss
JOIN store_locations sl ON ss.store_id = sl.storeid
WHERE sl.state = 'Maryland'
GROUP BY sl.storelocation
ORDER BY total_revenue DESC; 
-- Discovered though North Harford ia labeled in store there is no specifics other than volume to conclude why total revenue dominates the other stores. 
-- Q6 Reccomendation for where to focus sales attention in the next quarter. 
-- ================ RECOMMENDATION ==================================
#
