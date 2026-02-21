

IF OBJECT_ID('Bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE Bronze.crm_cust_info;

create table Bronze.crm_cust_info(
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_material_status VARCHAR(50),
cst_gndr VARCHAR(50),
cst_create_date DATE
);


IF OBJECT_ID('Bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE Bronze.crm_prd_info;

create table Bronze.crm_prd_info(
prd_id INT,
prd_key VARCHAR(50),
prd_nm VARCHAR(50),
prd_cost DECIMAL(10,2),
prd_line VARCHAR(50),
prd_start DATETIME,
prd_end_dt DATETIME
);


IF OBJECT_ID('Bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE Bronze.crm_sales_details;

create table Bronze.crm_sales_details(
sls_ord_num VARCHAR(50),
sls_prd_key VARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_du_dt INT,
sls_sales DECIMAL(10,2),
sls_quantity INT,
sls_price DECIMAL(10,2)
);


IF OBJECT_ID('Bronze.erp_CUST_AZ12','U') IS NOT NULL
	DROP TABLE Bronze.erp_CUST_AZ12;

create table Bronze.erp_CUST_AZ12(
CID VARCHAR(50),
BDATE DATE,
GEN VARCHAR(50)
);


IF OBJECT_ID('Bronze.erp_LOC_A101','U') IS NOT NULL
	DROP TABLE Bronze.erp_LOC_A101;

create table Bronze.erp_LOC_A101(
CID VARCHAR(50),
CNTRY VARCHAR(50)
);


IF OBJECT_ID('Bronze.PX_CAT_G1V2','U') IS NOT NULL
	DROP TABLE Bronze.PX_CAT_G1V2;

create table Bronze.PX_CAT_G1V2(
ID VARCHAR(50),
CAT VARCHAR(50),
SUBCAT VARCHAR(50),
MAINTENANCE VARCHAR(50)
);