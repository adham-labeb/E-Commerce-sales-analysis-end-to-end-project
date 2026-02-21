---------------------------------------------------
---------------------------------------------------

CREATE VIEW	gold.dim_customer AS
SELECT 
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr != 'Unknown' Then ci.cst_gndr -- CRM is the master for gender Info
	 Else COALESCE(ca.gen,'n/a')
End AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key = la.cid

---------------------------------------------------
---------------------------------------------------

CREATE VIEW	gold.dim_product AS
SELECT 
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS Product_key, 
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm As Product_name,
pn.cat_id As category_id,
pc.cat AS Category,
pc.subcat AS subCategory,
pc.maintenance,
pn.prd_cost AS cost,
pn.prd_line As Product_line,
pn.prd_start_dt AS start_date
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_PX_CAT_G1V2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL

---------------------------------------------------
---------------------------------------------------

-- 3- create the sales view
CREATE  VIEW gold.fact_sales AS
SELECT 
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS ship_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM Silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer cu
ON sd.sls_cust_id = cu.customer_id

---------------------------------------------------
---------------------------------------------------