# Czechoslovakia Banking Financial Data Analysis

## Project Overview
This project involves analyzing the Czechoslovakia Bank's financial data to provide actionable insights. The dataset includes anonymized information about accounts, clients, transactions, loans, and more, covering a five-year period. The analysis aims to identify trends, improve decision-making, and suggest potential areas for new financial products and services.

## Dataset Details
The dataset consists of the following tables:
1. **Account**: Account ID, open date, client ID, account type.
2. **Card**: Card ID, issue date, card type.
3. **Client**: Client ID, birthdate, gender, district information.
4. **Disposition**: Disposition ID, client ID, disposition type (owner, authorized, etc.).
5. **District**: District ID, name, demographic, and economic indicators.
6. **Loan**: Loan ID, issue date, account ID, loan amount.
7. **Order**: Order ID, account ID, issue date, description.
8. **Transaction**: Transaction ID, account ID, date, type, and amount.

## Key Objectives
The analysis aims to address the following questions:
1. What is the demographic profile of the clients, and how does it vary across districts?
2. How has the bank performed over the years, analyzed year- and month-wise?
3. What are the most common account types, and how do they differ in usage and profitability?
4. Which card types are most used, and what is the profitability of the credit card business?
5. What are the bank’s major expenses, and how can they be reduced?
6. What is the bank's loan portfolio distribution across purposes and client segments?
7. How can customer service and satisfaction levels be improved?
8. Can new financial products or services be introduced to attract customers and increase profitability?

## Steps in the Project
### 1. Data Cleaning
Performed data cleaning operations, such as:
- Standardizing date formats (e.g., updating account open dates to start from 2020).
- Removing duplicate records and handling missing values.

Code: `Data_Cleaning.ipynb`

### 2. Exploratory Data Analysis (EDA)
Conducted a detailed EDA using SQL to uncover patterns and trends in the data, addressing the key objectives outlined above.

Code: `EDA.sql`

### 3. Insights and Visualizations
Insights were presented in a dashboard, focusing on:
- Average balance per bank.
- Profitability trends.
- Customer demographics and loan portfolio analysis.

## Requirements
To run this project, you need the following:
- **Python Libraries**:
  - pandas
  - numpy
  - matplotlib
  - seaborn
- **SQL**: SQL Server Management Studio (SSMS) or a similar tool.
- **Jupyter Notebook**: For Python-based data cleaning.

## How to Run
1. Clone this repository.
2. Ensure the required libraries are installed.
3. Run the `Data_Cleaning.ipynb` file to preprocess the data.
4. Use the queries in `EDA.sql` to perform analysis in your SQL environment.
5. Visualize insights or generate dashboards using the cleaned data.

## Results
Key findings include:
- Detailed year- and month-wise performance of the bank.
- Demographic variations across districts.
- Identification of major expenses and profitability drivers.
- Suggestions for new financial products.
