# E-Commerce Sales Analysis Data Warehouse 🛒

## Project Description
Welcome to my E-Commerce Data Warehouse project! I built this to demonstrate a complete, end-to-end data pipeline using the Medallion Architecture (Bronze, Silver, and Gold layers). The goal of this project is to take raw, messy data from different systems, clean it up, and organize it so I can easily generate valuable business insights and sales predictions. I used SQL for the heavy lifting of data transformation and analysis, and Python to calculate metrics like Customer Lifetime Value (CLV) and predict future sales.

## Project Workflow
![Project Workflow](https://github.com/adham-labeb/E-Commerce-sales-analysis-end-to-end-project/blob/main/ASSETS/project%20work%20flow.png)

_Here's how it works: First, loading the raw files just as they are into the **Bronze** layer. Next, a stored procedure to clean up the data—fixing dates, standardizing text, handling missing values—and moves it to the **Silver** layer. Finally, the clean data is organized into simple, business-ready tables (Fact and Dimension tables) in the **Gold** layer. From there, it's ready for reports, dashboards, and Python analysis!_

## Source Data Catalog
The raw data comes from two main sources: an older CRM system and an ERP system. Before we clean it, the data is loaded into the **Bronze** layer exactly as it comes in. Here are the 6 tables to start 
![data flow](https://github.com/adham-labeb/E-Commerce-sales-analysis-end-to-end-project/blob/main/ASSETS/data%20flow%20across%20layers.png)
with:

### 1. **crm_cust_info**
- **Purpose:** This contains our basic customer details from the CRM.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| cst_id           | INT           | A unique number to identify each customer record.                                             |
| cst_key          | VARCHAR(50)   | A text ID we use to track the customer.                                                       |
| cst_firstname    | VARCHAR(50)   | The customer's first name.                                                                    |
| cst_lastname     | VARCHAR(50)   | The customer's last name.                                                                     |
| cst_material_status| VARCHAR(50) | The customer's marital status (like 'M' for Married or 'S' for Single).                       |
| cst_gndr         | VARCHAR(50)   | The customer's gender (like 'F' or 'M').                                                      |
| cst_create_date  | DATE          | The date when this customer was first added to our system.                                    |

---

### 2. **crm_prd_info**
- **Purpose:** This holds all the details about the products we sell.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| prd_id           | INT           | A unique number to identify the product.                                                      |
| prd_key          | VARCHAR(50)   | The unique product code we use for tracking.                                                  |
| prd_nm           | VARCHAR(50)   | The actual name of the product (e.g., 'Road-150 Red, 52').                                    |
| prd_cost         | DECIMAL(10,2) | How much it costs us to make or buy the product.                                              |
| prd_line         | VARCHAR(50)   | The broad category the product belongs to (like 'M' for Mountain bikes).                      |
| prd_start        | DATETIME      | The date we started selling this product.                                                     |
| prd_end_dt       | DATETIME      | The date we stopped selling this product (if applicable).                                     |

---

### 3. **crm_sales_details**
- **Purpose:** This is the big one! It contains all our historical sales transactions.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| sls_ord_num      | VARCHAR(50)   | The unique order number for the purchase.                                                     |
| sls_prd_key      | VARCHAR(50)   | Links back to the product bought (matches `crm_prd_info`).                                    |
| sls_cust_id      | INT           | Links back to the customer who bought it (matches `crm_cust_info`).                           |
| sls_order_dt     | INT           | The date the order was placed (stored as a number like 20210101).                             |
| sls_ship_dt      | INT           | The date the order was shipped to the customer.                                               |
| sls_du_dt        | INT           | The deadline or due date for the order.                                                       |
| sls_sales        | DECIMAL(10,2) | The total amount of money made from this specific item on the order.                          |
| sls_quantity     | INT           | How many of this item the customer bought.                                                    |
| sls_price        | DECIMAL(10,2) | The price of a single unit of this item.                                                      |

---

### 4. **erp_CUST_AZ12**
- **Purpose:** Extra customer details coming from our ERP system.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| CID              | VARCHAR(50)   | The customer ID used in the ERP system.                                                       |
| BDATE            | DATE          | The customer's date of birth.                                                                 |
| GEN              | VARCHAR(50)   | The customer's gender, written in older formats we need to clean up.                          |

---

### 5. **erp_LOC_A101**
- **Purpose:** Location information to tell us where our customers are from.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| CID              | VARCHAR(50)   | The customer ID, linking back to our other tables.                                            |
| CNTRY            | VARCHAR(50)   | The country the customer lives in (e.g., 'US', 'DE').                                         |

---

### 6. **PX_CAT_G1V2**
- **Purpose:** Helps us categorize our products into broader groups.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| ID               | VARCHAR(50)   | An internal ID for the category.                                                              |
| CAT              | VARCHAR(50)   | The main category of the product (like 'Bikes' or 'Clothing').                                |
| SUBCAT           | VARCHAR(50)   | A more specific sub-category (like 'Mountain Bikes' or 'Socks').                              |
| MAINTENANCE      | VARCHAR(50)   | Tells us if the product needs regular maintenance.                                            |

## Directory Structure
Here's how the project files are organized:
```text
📦 E-Commerce-sales-analysis-end-to-end-project
├── ASSETS/                             # Architecture diagrams and images
├── bronze layer/                       # SQL scripts to create tables and load raw data
├── silver layer/                       # Stored procedures that clean and transform the data
├── Gold layer/                         # Scripts to create our final, easy-to-use business views
├── SQL Analysis Queries/               # Cool SQL queries for digging into the data and generating reports
├── Python Script/                      # Python code for predictions and advanced metrics like CLV
├── database creation and schema.sql    # The script that creates the initial databases
└── README.md                           # This file right here!
```

## How it Built (Step-by-Step)

**1. Getting the Data (Bronze Layer)**
- First, setting up the database and schemas.
- Then, taking all the raw CSV files from our systems and loaded them straight into the `Bronze` tables using simple `BULK INSERT` commands. No cleaning yet, just getting the data in!

**2. Cleaning Things Up (Silver Layer)**
- writing a big stored procedure (`Silver.Load_Silver`) to do the heavy lifting.
- It fixes messy text (like removing extra spaces), standardizes basic info (like turning 'M' and 'F' into 'Male' and 'Female'), makes sure we don't have negative sales or quantities, and turns weird number-dates into actual SQL dates.

**3. Making it Useful (Gold Layer)**
- Then took the clean data and organized it into a classic Star Schema.
- creating "Dimension" tables for things we want to filter by (like `dim_customer` and `dim_product`) and a "Fact" table for the numbers (`fact_sales`). This makes the data super easy to query!

**4. Exploring the Data**
- We wrote basic SQL queries to check our work. We looked at total sales, checked the date ranges of our orders, and made sure our product numbers looked right.

**5. Digging Deeper (Advanced SQL Analysis)**
- Writing queries to see how sales changed over different months and quarters.
- Calculating running totals.
- Analysing which products were doing better than average and which categories brought in the most profit.
- Segmenting customers to see who the "VIPs" were and who was "New"!

**6. Automated SQL Reports**
- saving the best queries as permanent database Views (`report_customers`, `report_products`). This way, anyone can pull a quick report with all the KPIs (like average order value and customer lifespan) without having to write complex SQL every time.

**7. Python Predictive Modeling**
- Finally, using Python (`pandas` and `scikit-learn`) to read the clean Gold data.
- Calculating a Customer Lifetime Value (CLV) score and a churn risk score to see which customers we need to pay attention to.
- building a linear regression model to predict what our monthly sales will look like for the next 12 months!

## How to use the project yourself!
Want to run this on your own machine? Follow these steps:

1. Run the `database creation and schema.sql` file in your SQL Server to create the databases.
2. Check out the `bronze layer/bronze data dictionary` to understand the raw files.
3. Open `inserting data in the bronze layer.sql` (or whichever script you use to bulk load the data). 
   - **🛑 IMPORTANT:** You **must** change the file paths in the `FROM` clauses to point to wherever you saved the raw CSV files on your computer!
4. Go to the `silver layer` folder and run `Stored procedure for loading data in the silver layer.sql`.
5. Run the `gold layer views.sql` in the `Gold layer` folder to create your final tables.
6. Now the fun part: start running the queries inside the `SQL Analysis Queries` folder!
7. **🛑 IMPORTANT:** If you want to run the python script (`analysis.py`), don't forget to open the script file and change `gold_dir` and `out_dir` so python knows where to find your files and where to save the output CSVs!
