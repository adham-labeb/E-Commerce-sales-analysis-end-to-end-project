# SQL Analysis Queries Explanation

## Overview
Once the raw data is cleaned in the *Silver Layer* and aggregated into business-ready dimensions and facts in the *Gold Layer*, we can finally run analytics to extract valuable insights. The `SQL Analysis Queries` directory contains three primary SQL scripts designed to explore the data, perform advanced predictive/cumulative analytics, and generate robust automated business reports.

Here is a breakdown of what each SQL script does:

---

## 1. Basic Data Exploration (`Basic data exploration.sql`)
This script serves as the initial "sanity check" and foundational exploration of the data. Before running complex analysis, we use these queries to understand the shape, size, and boundaries of our dataset.

**Key Operations:**
- **Database Architecture Check:** Explores all tables and columns present in the Gold schema to verify structure.
- **Categorical Exploration:** Validates the distinct categories available in dimensions like tracking unique `country`, `marital_status`, and `gender` parameters from customers, as well as distinct `Category` and `Product_line` from products.
- **Date Boundaries:** Calculates the absolute minimum and maximum constraints, like finding the age range between the oldest and youngest customers, determining the full lifespan of our product catalogue, and extracting the first and last `order_date` ever placed.
- **Shipping Logistics:** Checks the minimum and maximum days it takes to ship an order (fastest vs slowest order-to-ship dates) and evaluates due date buffers.
- **Core Aggregations:** Calculates high-level top-tier business metrics including:
  - Total Lifetime Sales Revenue & Total Items Sold.
  - Total Unique Customers & Products.
  - Revenue slices grouped specifically by Country, Gender, and Category.
- **Ranking Functions:** Utilizes `ROW_NUMBER()` and `TOP 5` logic to isolate the highest and lowest performing products and identifying the top 10 best customers by revenue versus the 3 worst.

---

## 2. Advanced Analysis (`Advanced Analysis.sql`)
This script dives deeper into the relational logic to answer complex business questions involving trends, moving analytics, and detailed segmentation.

**Key Operations:**
- **Change Over Time:** Groups total sales, customers, and sold quantities by specific `Quarter` and `Month` cadences, allowing us to build line charts to spot seasonal trends.
- **Cumulative Analysis (Running Totals):** Uses Window Functions (`SUM() OVER(PARTITION BY...)`) to calculate rolling "running totals" for sales, customers, and sold items accumulating strictly within boundaries for each distinct Year.
- **Performance Benchmarking:** Compares each product's current year sales directly against its own overall historical Average Sales (`Above/Below AVG`) and to its immediate Previous Year's performance (`Increase/Decrease`) utilizing the `LAG()` function.
- **Parts-to-Whole Ratio:** Evaluates total categorical sales and profits explicitly as a percentage metric against the *entire* company's overall fractional revenue base.
- **Data Segmentation:**
  - **Product Costs:** Sorts products into cost-range buckets cleanly ('Below 100', '100-500', 'Above 1000').
  - **Customer Spending (VIP Mapping):** Isolates customers calculating their individual 'lifespans'. Anyone holding a lifespan over 12 months with more than $5000 spent is tagged as a **'VIP'**, whereas those under the spending bound are **'Regular'**, and those newer than 12 months are flagged as **'New'**.

---

## 3. Automated Reports (`reports.sql`)
Instead of running loose queries manually, this script creates persistent SQL `VIEWS`. A view acts as an automated virtual table that consolidates difficult queries into a single, easily readable table for stakeholders.

**Key Operations:**
- **`Gold.report_customers`:** Creates a master customer view summarizing their behavior. 
  - Grabs all customer metrics combining them with their lifespan and tagging them dynamically into `'age_groups'` (e.g., '30-39', 'Under 20') and their spending segments (`VIP/Regular`).
  - Formulates important KPIs per customer: **Average value per order**, **Average monthly spend**, and **Recency** (exact months since their last recorded purchase).

- **`Gold.report_products`:** Creates a master product performance view.
  - Groups products and tags them categorically based on strict lifetime revenue generated: `High-Performer` (>50k), `Mid-Range`, or `Low-Performer`.
  - Calculates granular KPIs per product: Total unique customers who bought it, absolute product lifespan, and **Average Order Revenue** specifically per item.
