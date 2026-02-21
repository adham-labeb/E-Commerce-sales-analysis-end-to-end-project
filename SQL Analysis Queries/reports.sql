/*
====================================================================
Customer Report
====================================================================

Purpose:
  - This report consolidates key customer metrics and behaviors

Highlights:
  1. Gathers essential fields such as names, ages, and transaction details.
  2. Segments customers into categories (VIP, Regular, New) and age groups.
  3. Aggregates customer-level metrics:
     - total orders
     - total sales
     - total quantity purchased
     - total products
     - lifespan (in months)
  4. Calculates valuable KPIs:
     - recency (months since last order)
     - average order value
     - average monthly spend

====================================================================
*/
CREATE VIEW Gold.report_customers AS
WITH customers_details AS (
	SELECT 
		FS.order_number,
		FS.product_key,
		FS.order_date,
		FS.sales_amount,
		FS.quantity,
		DC.customer_key,
		DC.customer_number,
		CONCAT(DC.first_name,' ',DC.last_name) AS customer_name,
		DATEDIFF(year,DC.birthdate,GETDATE()) AS age
	FROM 
		Gold.fact_sales AS FS
	LEFT JOIN 
		Gold.dim_customer AS DC
	ON 
		DC.customer_key = FS.customer_key
	WHERE
		FS.order_date IS NOT NULL),
customer_aggregation AS (
SELECT 		
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_order,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
FROM 
	customers_details
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age)

SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
			WHEN age < 20 THEN 'Under 20'
			WHEN age BETWEEN 20 and 29 THEN '20-29'
			WHEN age BETWEEN 30 and 39 THEN '30-39'
			WHEN age BETWEEN 40 and 49 THEN '40-49'
			ELSE '50 and above'
		END AS age_group,
	CASE 
			WHEN lifespan >=12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >=12 AND total_sales <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment,
	total_order,
	total_sales,
	CASE 
			WHEN total_order = 0 THEN 0
			ELSE total_sales / total_order
		END AS avg_per_order,
	CASE 
			WHEN lifespan = 0 THEN total_sales
			ELSE total_sales / lifespan
		END AS avg_monthly_spend,
	total_quantity,
	total_products,
	last_order_date,
	lifespan,
	DATEDIFF(MONTH,last_order_date,GETDATE()) AS months_from_last_order
FROM 
	customer_aggregation

/*
====================================================================
Product Report
====================================================================

Purpose:
  - This report consolidates key product metrics and behaviors.

Highlights:
  1. Gathers essential fields such as product name, category, subcategory, and cost.
  2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
  3. Aggregates product-level metrics:
     - total orders
     - total sales
     - total quantity sold
     - total customers (unique)
     - lifespan (in months)
  4. Calculates valuable KPIs:
     - recency (months since last sale)
     - average order revenue (AOR)
     - average monthly revenue

====================================================================
*/

CREATE VIEW Gold.report_products AS
WITH product_details AS (
	SELECT 
		FS.order_number,
		FS.customer_key,
		FS.order_date,
		FS.sales_amount,
		FS.quantity,
		DP.product_key,
		DP.product_name,
		DP.category,
		DP.subcategory,
		DP.cost
	FROM 
		Gold.fact_sales AS FS
	LEFT JOIN 
		Gold.dim_product AS DP
	ON 
		DP.product_key = FS.product_key
	WHERE
		FS.order_date IS NOT NULL),
product_aggregation AS (
SELECT 		
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customers,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
FROM 
	product_details
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost)

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	CASE 
			WHEN total_sales > 50000 THEN 'High-Performer'
			WHEN total_sales >= 10000 THEN 'Mid-Range'
			ELSE 'Low-Performer'
		END AS product_segment,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	lifespan,
	last_order_date,
	DATEDIFF(MONTH,last_order_date,GETDATE()) AS recency,
	CASE 
			WHEN total_orders = 0 THEN 0
			ELSE total_sales / total_orders
		END AS avg_order_revenue,
	CASE 
			WHEN lifespan = 0 THEN total_sales
			ELSE total_sales / lifespan
		END AS avg_monthly_revenue
FROM 
	product_aggregation;

