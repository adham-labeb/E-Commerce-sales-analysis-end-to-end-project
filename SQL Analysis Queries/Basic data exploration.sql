-- Understanding our data

-- EXplore ALL Objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES ; 

-- Explore columns of wanted tables
SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'Gold';

-- Explore categories in the dimension columns and date in the date columns
-- dim_customer
SELECT DISTINCT country FROM Gold.dim_customer;

SELECT DISTINCT marital_status FROM Gold.dim_customer;

SELECT DISTINCT gender FROM Gold.dim_customer;

SELECT
MIN(year(birthdate)) AS oldest_customer_birth_year,
DATEDIFF (year,MIN(birthdate),GETDATE()) AS oldest_customer_age,
MAX(year(birthdate)) AS youngest_customer_birth_year,
DATEDIFF (year,MAX(birthdate),GETDATE()) AS youngest_customer_age
FROM Gold.dim_customer


-- dim_product
SELECT DISTINCT Category FROM Gold.dim_product;

SELECT DISTINCT subCategory FROM Gold.dim_product;

SELECT DISTINCT maintenance FROM Gold.dim_product;

SELECT DISTINCT Product_line FROM Gold.dim_product;

SELECT
MIN(year(start_date)) AS oldest_product_manufacture_year,
DATEDIFF (year,MIN(start_date),GETDATE()) AS oldest_product_manufacture_age,
MAX(year(start_date)) AS newst_product_manufacture_year,
DATEDIFF (year,MAX(start_date),GETDATE()) AS newst_product_manufacture_age
FROM Gold.dim_product;


-- fact_sales
SELECT 
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(year,MIN(order_date),MAX(order_date)) AS order_range_year
FROM gold.fact_sales

SELECT
MIN(DATEDIFF(DAY,order_date,ship_date)) AS fastst_order_to_ship_date,
MAX(DATEDIFF(DAY,order_date,ship_date)) AS slowst_order_to_ship_date,
MIN(DATEDIFF(DAY,ship_date,due_date)) AS fastst_ship_to_due_date,
MAX(DATEDIFF(DAY,ship_date,due_date)) AS slowst_ship_to_due_date,
MIN(DATEDIFF(DAY,order_date,due_date)) AS fastst_order_to_due_date,
MAX(DATEDIFF(DAY,order_date,due_date)) AS slowst_order_to_due_date
FROM Gold.fact_sales

-- exploring the main measure in the fact_sales table
SELECT
'Total Sales' AS measure_name ,SUM(sales_amount ) AS measure_value FROM Gold.fact_sales
UNION ALL
SELECT 
'total_sold_items' AS measure_name, SUM(quantity) AS measure_value FROM Gold.fact_sales
UNION ALL
SELECT
'avg_price' AS measure_name, AVG(price) AS measure_value FROM Gold.fact_sales
UNION ALL
SELECT
'total_orders' AS measure_name, COUNT(DISTINCT order_number) AS  measure_value FROM Gold.fact_sales
UNION ALL
SELECT
'total_products' AS measure_name, COUNT(DISTINCT product_key) AS measure_value FROM Gold.dim_product
UNION ALL
SELECT
'total_selling_products' AS measure_name, COUNT(DISTINCT product_key) AS measure_value FROM Gold.fact_sales
UNION ALL
SELECT
'total_customer' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM Gold.dim_customer
UNION ALL
SELECT
'total_customer_who_ordered' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM Gold.fact_sales


-- gropuing and aggrigiations
--1- total customers by country
SELECT DC.country , COUNT(DISTINCT FS.customer_key) AS total_customers
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS DC
ON FS.customer_key = DC.customer_key
GROUP BY DC.country
ORDER BY total_customers DESC

--2- total customers by gender
SELECT DC.gender , COUNT(DISTINCT FS.customer_key) AS total_customers
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS DC
ON FS.customer_key = DC.customer_key
GROUP BY DC.gender
ORDER BY total_customers DESC

--3- total products by category
SELECT Category , COUNT(DISTINCT product_id) AS total_products
FROM Gold.dim_product
GROUP BY category
ORDER BY total_products DESC

--4- average costs in each category
SELECT Category,AVG(cost) AS average_cost
FROM  Gold.dim_product 
GROUP BY Category
ORDER BY average_cost DESC

--5- total profit by category
SELECT DP.Category,SUM((FS.price - DP.cost)* FS.quantity) AS Total_profit
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_product AS DP
ON FS.product_key = DP.Product_key
GROUP BY DP.Category
ORDER BY Total_profit DESC

--6- total revenue by category
SELECT DP.Category,SUM(FS.sales_amount) AS Total_revenue
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_product AS DP
ON FS.product_key = DP.Product_key
GROUP BY DP.Category
ORDER BY Total_revenue DESC

--7- total revenue by customers
SELECT C.customer_key,C.first_name,C.last_name,SUM(FS.sales_amount) AS Total_revenue
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS c
ON FS.customer_key = C.customer_key
GROUP BY C.customer_key,C.first_name,C.last_name
ORDER BY Total_revenue DESC

--8- quantity_sold by country
SELECT C.country,SUM(FS.quantity) AS Total_quantity
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS c
ON FS.customer_key = C.customer_key
GROUP BY C.country
ORDER BY Total_quantity DESC


-- Ranking analysis

--1- top 5 heighest revenue products

SELECT TOP 5 DP.Product_name,SUM(FS.sales_amount) AS Total_revenue
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_product AS DP
ON FS.product_key = DP.Product_key
GROUP BY DP.Product_name
ORDER BY Total_revenue DESC;

--Using window functions
SELECT * 
FROM (
		SELECT 
		ROW_NUMBER() OVER(ORDER BY SUM(FS.sales_amount) DESC) AS rank_product,
		DP.Product_name,
		SUM(FS.sales_amount) AS Total_revenue
		FROM 
		Gold.fact_sales AS FS INNER JOIN Gold.dim_product AS DP
		ON FS.product_key = DP.Product_key
		GROUP BY DP.Product_name)t
WHERE rank_product <= 5 ;


--2-Top 5 worst performing product 
SELECT TOP 5 DP.Product_name,SUM(FS.sales_amount) AS Total_revenue
FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_product AS DP
ON FS.product_key = DP.Product_key
GROUP BY DP.Product_name
ORDER BY Total_revenue 

-- Using window function 

SELECT * 
FROM (
		SELECT 
		ROW_NUMBER() OVER(ORDER BY SUM(FS.sales_amount) ASC) AS rank_product,
		DP.Product_name,
		SUM(FS.sales_amount) AS Total_revenue
		FROM 
		Gold.fact_sales AS FS INNER JOIN Gold.dim_product AS DP
		ON FS.product_key = DP.Product_key
		GROUP BY DP.Product_name)t
WHERE rank_product <= 5 ;


-- 3- top 10 customer by reveneue and worst 3 customer by revenue
SELECT * 
FROM (
		SELECT 
		ROW_NUMBER() OVER(ORDER BY SUM(FS.sales_amount) DESC) rank_customer,
		C.customer_key,
		C.first_name,
		C.last_name,
		SUM(FS.sales_amount) AS Total_revenue
		FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS c
		ON FS.customer_key = C.customer_key
		GROUP BY C.customer_key,C.first_name,C.last_name)t
WHERE rank_customer <= 10
UNION ALL 
SELECT * 
FROM (
		SELECT 
		ROW_NUMBER() OVER(ORDER BY SUM(FS.sales_amount) DESC) rank_customer,
		C.customer_key,
		C.first_name,C.last_name,
		SUM(FS.sales_amount) AS Total_revenue
		FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS c
		ON FS.customer_key = C.customer_key
		GROUP BY C.customer_key,C.first_name,C.last_name)t
WHERE rank_customer >= (SELECT MAX(rank_customer) - 2 
							   FROM (SELECT 
									ROW_NUMBER() OVER(ORDER BY SUM(FS.sales_amount) DESC) rank_customer,
									C.customer_key,
		C.first_name,C.last_name,
		SUM(FS.sales_amount) AS Total_revenue
		FROM Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS c
		ON FS.customer_key = C.customer_key
		GROUP BY C.customer_key,C.first_name,C.last_name)t)

-- Using CTE

WITH Customer_Revenue AS (
							SELECT 
								ROW_NUMBER() OVER(ORDER BY SUM(FS.sales_amount) DESC)AS rank_customer,
								C.customer_key,
								c.first_name,
								c.last_name,
								SUM(FS.sales_amount) AS Total_revenue
							FROM 
								Gold.fact_sales AS FS INNER JOIN Gold.dim_customer AS C
							ON 
								FS.customer_key = C.customer_key
							GROUP BY 
								C.customer_key,
								c.first_name,
								c.last_name
								)

SELECT * 
FROM 
	Customer_Revenue
WHERE 
	rank_customer <= 10 
UNION ALL 
SELECT * 
FROM 
	Customer_Revenue
WHERE 
	rank_customer >= (SELECT MAX(rank_customer)-2 From Customer_Revenue) 
