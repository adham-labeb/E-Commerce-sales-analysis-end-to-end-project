import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
import os
import warnings

warnings.filterwarnings('ignore')

gold_dir = r"G:\data_analysis_projects\SQL Data Werehouse Project\gold layer"
out_dir = r"G:\data_analysis_projects\SQL Data Werehouse Project\python script"
os.makedirs(out_dir, exist_ok=True)

# 1. Load Data
cust_cols = ['customer_key', 'alt_key', 'customer_id', 'first_name', 'last_name', 'country', 'marital_status', 'gender', 'birthdate', 'other_date']
df_cust = pd.read_csv(os.path.join(gold_dir, "dim_customer.csv"), names=cust_cols, na_values=['NULL'])
df_sales = pd.read_csv(os.path.join(gold_dir, "fact_sales.csv"), header=None, na_values=['NULL'])
df_sales = df_sales.rename(columns={0: 'order_id', 2: 'customer_key', 3: 'order_date', 6: 'sales_amount'})

df_sales['order_date'] = pd.to_datetime(df_sales['order_date'])
current_date = df_sales['order_date'].max()

# CLV Churn
cust_sales = df_sales.groupby('customer_key').agg(
    total_order=('order_id', 'nunique'),
    total_sales=('sales_amount', 'sum'),
    last_order_date=('order_date', 'max')
).reset_index()

df_clv = df_cust[['customer_key', 'customer_id', 'gender', 'country', 'birthdate']].merge(cust_sales, on='customer_key', how='inner')
df_clv['birthdate'] = pd.to_datetime(df_clv['birthdate'], errors='coerce')
df_clv['age'] = (current_date - df_clv['birthdate']).dt.days // 365
df_clv['recency'] = (current_date - df_clv['last_order_date']).dt.days

max_total_sales = df_clv['total_sales'].max()
max_total_orders = df_clv['total_order'].max()
max_recency = df_clv['recency'].max()

df_clv['clv_score'] = ((df_clv['total_sales'] / max_total_sales) * 0.6 + (df_clv['total_order'] / max_total_orders) * 0.4) * 100
df_clv['churn_risk_score'] = (df_clv['recency'] / max_recency) * 100

clv_out = df_clv[['customer_id', 'gender', 'country', 'age', 'total_order', 'total_sales', 'clv_score', 'churn_risk_score']]
clv_out.to_csv(os.path.join(out_dir, "clv_churn.csv"), index=False)
print("clv_churn.csv created successfully.")

# Sales Report
df_sales['order_month'] = df_sales['order_date'].dt.to_period('M')
monthly_sales = df_sales.groupby('order_month')['sales_amount'].sum().reset_index()
monthly_sales.rename(columns={'sales_amount': 'Total_Sales'}, inplace=True)
monthly_sales = monthly_sales.sort_values('order_month').reset_index(drop=True)
monthly_sales['year'] = monthly_sales['order_month'].dt.year
monthly_sales['running_tota_sales'] = monthly_sales.groupby('year')['Total_Sales'].cumsum()
monthly_sales['order_date'] = monthly_sales['order_month'].dt.strftime('%Y-%b')

report_actual = monthly_sales[['order_date', 'Total_Sales', 'running_tota_sales']].copy()

# LR
monthly_sales['month_idx'] = np.arange(len(monthly_sales))
X = monthly_sales[['month_idx']]
y = monthly_sales['Total_Sales']

model = LinearRegression()
model.fit(X, y)

pred_months = pd.period_range(start='2014-01', end='2014-12', freq='M')
base_month = monthly_sales['order_month'].min()
pred_idx = [[(m - base_month).n] for m in pred_months]

pred_sales = model.predict(pred_idx)

df_pred = pd.DataFrame({
    'order_month': pred_months,
    'Total_Sales': pred_sales
})
df_pred['year'] = df_pred['order_month'].dt.year
df_pred['running_tota_sales'] = df_pred.groupby('year')['Total_Sales'].cumsum()
df_pred['order_date'] = df_pred['order_month'].dt.strftime('%Y-%b')

report_pred = df_pred[['order_date', 'Total_Sales', 'running_tota_sales']]

final_report = pd.concat([report_actual, report_pred], ignore_index=True)
final_report.to_csv(os.path.join(out_dir, "sales_report.csv"), index=False)
print("sales_report.csv created successfully.")
