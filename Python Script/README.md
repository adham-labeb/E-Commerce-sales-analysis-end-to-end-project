# Python Script Explanation

## Overview
The python script (`analysis.py`) inside the `python script` directory serves as an automated analysis script that consumes the raw, cleaned aggregated data from the Gold layer to calculate complex customer metrics and forecast future sales trajectory using Machine Learning (Linear Regression).

## Step-by-Step Breakdown

### 1. Data Loading & Parsing
- The script imports essential data analysis and machine learning tools: `pandas`, `numpy`, and `scikit-learn`.
- It dynamically reads the raw Gold layer views (`dim_customer.csv` and `fact_sales.csv`) directly into Pandas DataFrames.
- Null values mapping to the string `'NULL'` are caught and dropped, and date columns like `order_date` and `birthdate` are converted explicitly into functional Datetime objects for manipulation.

### 2. Customer Lifetime Value (CLV) & Churn Risk Score
The script isolates customers and calculates two important business metrics: **CLV** and **Churn Risk**.
- **Aggregations:** For every unique customer, it calculates their `total_orders`, `total_sales`, and pinpoints their `last_order_date`.
- **Calculating Age:** Calculates each customer's age by subtracting their `birthdate` from the overall `current_date` (mapped as the most recent order date in the dataset).
- **Recency:** Evaluates how many days have passed since a customer's last purchase (`current_date` - `last_order_date`).
- **Scoring Formulas:** 
  - Calculates a normalized **CLV Score (0-100)** by assigning a 60% weight to their total sales versus the max sales, and a 40% weight to their total orders versus the max orders.
  - Generates a **Churn Risk Score (0-100)** defining how likely they are to leave by dividing their recency by the maximum recency observed.
- Outputs this final aggregated metric table directly to `clv_churn.csv`.

### 3. Sales Forecasting (Linear Regression)
The script then takes the historical timeline of the business and predicts next year's sales.
- **Historical Scaling:** Formats all data to match monthly intervals (`order_month`) and calculates the `running_total_sales` compounding month over month for each historical year.
- **Model Training:** Fits a `LinearRegression` model using the historical timeline index (`month_idx`) against the dependent variable `Total_Sales`.
- **Predictive Horizon:** Generates future dataset indexes spanning January 2014 to December 2014, and asks the model to predict the monetary outputs for those months.
- **Final Output:** It merges the historical known actuals with the generated 2014 predictions, formatting rolling cumulative totals tracking across 2014, and exports the final sequence to `sales_report.csv`.
