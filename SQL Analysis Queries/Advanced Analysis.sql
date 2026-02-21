-- ## Change over time analysis
-- sales by quarter 
SELECT 
	CONCAT(YEAR(order_date),' - Q',DATEPART(QUARTER,order_date)) AS Querter_Year,
	SUM(sales_amount) AS Total_Sales,
	COUNT(DISTINCT customer_key) AS Total_Customers,
	SUM(quantity) AS Total_Sold_items
FROM 
	Gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	YEAR(order_date),DATEPART(QUARTER,order_date)
ORDER BY
	YEAR(order_date),DATEPART(QUARTER,order_date)

-- Sales by month

SELECT 
	FORMAT(DATETRUNC(MONTH,order_date),'yyyy-MMM') AS order_date,
	SUM(sales_amount) AS Total_Sales,
	COUNT(DISTINCT customer_key) AS Total_Customers,
	SUM(quantity) AS Total_Sold_items
FROM 
	Gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	DATETRUNC(MONTH,order_date)
ORDER BY
	DATETRUNC(MONTH,order_date)

-- ## Cumulative Analysis
SELECT 
	FORMAT (order_date,'yyyy-MMM') AS order_date,
	Total_Sales,
	SUM(Total_Sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_tota_sales,
	Total_Customers,
	SUM(Total_Customers) OVER (ORDER BY order_date) AS running_total_customers,
	Total_Sold_items,
	SUM(Total_Sold_items) OVER (ORDER BY order_date) AS running_total_sold_items
FROM 
	(
		SELECT 
			DATETRUNC(MONTH,order_date) AS order_date,
	SUM(sales_amount) AS Total_Sales,
	COUNT(DISTINCT customer_key) AS Total_Customers,
	SUM(quantity) AS Total_Sold_items
FROM 
	Gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	DATETRUNC(MONTH,order_date)
	)t


-- ## Performance Analysis
/* Analyze the yearly performance of products by comparing each product's sales 
 to both its AVG sales performance and the previous year's sales
*/
WITH yearly_product_sales AS (
SELECT 
YEAR(FS.order_date) AS order_year,
DP.Product_name,
SUM(FS.sales_amount) AS current_sales
FROM 
Gold.fact_sales AS FS 
LEFT JOIN 
Gold.dim_product AS DP
ON 
FS.product_key = DP.product_key
WHERE FS.order_date IS NOT NULL
GROUP BY 
YEAR(FS.order_date),
DP.Product_name
)
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above AVG'
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below AVG'
	 ELSE 'AVG'
	 END AS AVG_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_from_previous_year,
CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
	 END AS previous_year_change
FROM yearly_product_sales 
ORDER BY 
product_name,order_year;

-- ## Part to Whole Analysis
-- Which categorie contribute the most to overall sales
With category_sales AS (
SELECT 
Category,
SUM(sales_amount) AS total_sales_by_category,
SUM(quantity) AS total_item_sold_by_category,
SUM((price - cost) * quantity) AS profit
FROM Gold.fact_sales AS FS 
LEFT JOIN 
Gold.dim_product AS DP
ON 
DP.Product_key = FS.product_key
GROUP BY category)
SELECT 
Category,
total_sales_by_category,
--SUM(total_sales) OVER() overall_sales,
concat(ROUND((CAST(total_sales_by_category AS FLOAT)  / SUM(total_sales_by_category)OVER()) *100,2),'%') AS sales_percentage_of_total, 
total_item_sold_by_category,
concat(ROUND((CAST(total_item_sold_by_category AS FLOAT)  / SUM(total_item_sold_by_category)OVER()) *100,2),'%') AS sold_item_percentage_of_total,
profit,
concat(ROUND((CAST(profit AS FLOAT)  / SUM(profit)OVER()) *100,2),'%') AS profit_percentage_of_total
FROM 
category_sales
ORDER BY total_sales_by_category DESC

-- ## Data Segmentation
-- Segment products into cost ranges and count how many products fall into each segment
WITH product_segments AS (
SELECT 
product_key,
product_name,
cost,
CASE 
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_range
FROM 
Gold.dim_product)
SELECT 
	cost_range,
	COUNT (product_key) AS total_products
FROM
	product_segments
GROUP BY 
	cost_range
ORDER BY 
	total_products DESC

-- customer segmentation
/* Group 1 : vip :12 months of history and more than 5k spending
Group 2 : regular :12 months of history and equal or less than 5k spending
Group 3 : new :less than 12 months of history 
find the total number of customer for each segment
*/
WITH customer_spending AS (
SELECT 
	DC.customer_key,
	SUM(FS.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM 
	Gold.fact_sales AS FS
LEFT JOIN
	Gold.dim_customer AS DC
ON
	FS.customer_key = DC.customer_key
GROUP BY 
	DC.customer_key)
SELECT 
	customer_segment,
	COUNT(customer_key) AS total_customer
FROM(
	SELECT 
		customer_key,
		CASE 
			WHEN lifespan >=12 AND total_spending > 5000 THEN 'VIP'
			WHEN lifespan >=12 AND total_spending <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment	
	FROM
		customer_spending)t
GROUP BY 
	customer_segment
ORDER BY 
	total_customer DESC



