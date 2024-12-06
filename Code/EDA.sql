-- Creating a database
CREATE DATABASE CzechoslovakiaBank;

-- Using the database that we have created
USE CzechoslovakiaBank;


-- Creating a new column Age by subtracting the birth_date and the max date from the transaction table
-- Fetching the max date from the transaction table
DECLARE @MaxTransactionDate DATE;
SELECT @MaxTransactionDate = MAX(Date) FROM dbo.transactions

-- Creating a formula for calculating the age
SELECT DATEDIFF(YEAR, Birth_Number , @MaxTransactionDate) AS 'Age' FROM dbo.client

-- Adding the column in the client table
ALTER TABLE client
ADD Age INTEGER

-- Adding the age values into the Age column in the client table
DECLARE @MaxTransactionDate DATE;
SELECT @MaxTransactionDate = MAX(Date) FROM dbo.transactions

UPDATE client
SET Age = (DATEDIFF(YEAR, Birth_Number , @MaxTransactionDate))

-- Fetching the client table
SELECT TOP 10 * FROM client

------------------------------------------------------------------------------------------------------------------------------------------
-- In the transactio table we need to change the date years
--2021 -> 2022
--2020 -> 2021
--2019 -> 2020
--2018 -> 2019
--2017 -> 2018
--2016 -> 2017

SELECT YEAR(DATE) AS 'Txn_Year', COUNT(*) AS 'Total_Txn' FROM dbo.transactions
WHERE Bank IS NULL
GROUP BY YEAR(DATE)
ORDER BY 1

-- For year 2021
UPDATE dbo.transactions
SET Date = DATEADD(YEAR, 1, Date)
WHERE YEAR(Date) = 2021

-- For year 2020
UPDATE dbo.transactions
SET Date = DATEADD(YEAR, 1, Date)
WHERE YEAR(Date) = 2020

-- For year 2019
UPDATE dbo.transactions
SET Date = DATEADD(YEAR, 1, Date)
WHERE YEAR(Date) = 2019

-- For year 2018
UPDATE dbo.transactions
SET Date = DATEADD(YEAR, 1, Date)
WHERE YEAR(Date) = 2018

-- For year 2017
UPDATE dbo.transactions
SET Date = DATEADD(YEAR, 1, Date)
WHERE YEAR(Date) = 2017

-- For year 2016
UPDATE dbo.transactions
SET Date = DATEADD(YEAR, 1, Date)
WHERE YEAR(Date) = 2016

SELECT YEAR(DATE) AS 'Txn_Year', COUNT(*) AS 'Total_Txn' FROM dbo.transactions
WHERE Bank IS NULL
GROUP BY YEAR(DATE)
ORDER BY 1

------------------------------------------------------------------------------------------------------------------------------------------
-- Update the bank where its is NULL in the transaction table
-- 2022 -> Sky Bank
-- 2021 -> DBS Bank
-- 2019 -> Northern Bank
-- 2018 -> Southern Bank
-- 2017 -> Canara Bank

-- 2022
UPDATE dbo.transactions
SET Bank = 'Sky Bank'
WHERE BANK IS NULL AND YEAR(DATE) = 2022

-- 2021
UPDATE dbo.transactions
SET Bank = 'DBS Bank'
WHERE BANK IS NULL AND YEAR(DATE) = 2021

-- 2019
UPDATE dbo.transactions
SET Bank = 'Northern Bank'
WHERE BANK IS NULL AND YEAR(DATE) = 2019

-- 2018
UPDATE dbo.transactions
SET Bank = 'Southern Bank'
WHERE BANK IS NULL AND YEAR(DATE) = 2018

-- 2017
UPDATE dbo.transactions
SET Bank = 'Canara Bank'
WHERE BANK IS NULL AND YEAR(DATE) = 2017

------------------------------------------------------------------------------------------------------------------------------------------
-- Updating the transactions table where the Bank is NULL with SBI Bank
UPDATE dbo.transactions
SET Bank = 'SBI Bank'
WHERE Bank IS NULL

------------------------------------------------------------------------------------------------------------------------------------------
SELECT TOP 10 * FROM [dbo].[account]
SELECT TOP 10 * FROM [dbo].[transactions]
SELECT TOP 10 * FROM [dbo].[card]
SELECT TOP 10 * FROM [dbo].[client]
SELECT TOP 10 * FROM [dbo].[disposition]
SELECT TOP 10 * FROM [dbo].[district]
SELECT TOP 10 * FROM [dbo].[loan]
SELECT TOP 10 * FROM [dbo].[order]
SELECT TOP 10 * FROM dbo.Transaction_KPI

------------------------------------------------------------------------------------------------------------------------------------------


-- Creating a date table for EDA
WITH DateRange AS (
    SELECT CAST('2015-01-01' AS DATE) AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateRange
    WHERE DATEADD(DAY, 1, DateValue) <= '2023-01-01'
)
SELECT DateValue,
YEAR(DateValue) AS 'Year',
MONTH(DateValue) AS 'Month',
CONCAT(YEAR(DateValue), '-', FORMAT(MONTH(DateValue), '00')) AS 'YearMonth',
CASE 
        WHEN MONTH(DateValue) >= 4 
        THEN CONCAT('Financial Year ', YEAR(DateValue), '-', YEAR(DateValue) + 1)
        ELSE CONCAT('Financial Year ', YEAR(DateValue) - 1, '-', YEAR(DateValue))
    END AS FinancialYear
INTO dbo.DateDimension
FROM DateRange
OPTION (MAXRECURSION 0); -- Allows for recursion beyond the default limit of 100


-- We are assuming the balance as the last transaction date
DROP TABLE IF EXISTS #Temp

SELECT ACCOUNT_ID,YEAR(DATE) AS Transaction_Year,
   MONTH(DATE) AS Transaction_Month,
   MAX(DATE) AS Latest_Transaction_Date
   INTO #Temp
   FROM dbo.transactions
   GROUP BY ACCOUNT_ID, MONTH(DATE), YEAR(DATE)
   ORDER BY 1,2,3


-- We are assuming that the last date whatever credit transaction has happened which is in credit is the balance
-- Creating dbo.account_last_transaction_balance table
SELECT LTD.*,T.Balance
INTO dbo.account_last_transaction_balance
FROM dbo.transactions AS T
INNER JOIN 
#Temp LTD 
ON T.ACCOUNT_ID = LTD.ACCOUNT_ID AND T.DATE = LTD.Latest_Transaction_Date
WHERE T.TYPE = 'Credit'
ORDER BY T.ACCOUNT_ID,LTD.Transaction_Year,LTD.Transaction_Month;

SELECT TOP 10 * FROM dbo.account_last_transaction_balance ALTB


-- Creating a Transaction KPI table
SELECT A.Account_Type,
T.Bank,
YEAR(T.Date) AS Transaction_Year,
MONTH(T.Date) AS Transaction_Month,
COUNT(DISTINCT T.Account_Id) Total_Accounts,
COUNT(CASE WHEN T.Type = 'Credit' THEN 1 END) AS Total_Amt_Deposit,
COUNT(CASE WHEN T.Type = 'Withdrawal' THEN 1 END) AS Total_Amt_Withdrawal,
SUM(ALTB.Balance) AS Total_Balance,
(SUM(ALTB.Balance) / COUNT(DISTINCT T.Account_Id)) AS AvgBalance
INTO dbo.Transaction_KPI
FROM dbo.transactions T
INNER JOIN dbo.account_last_transaction_balance ALTB
ON T.Account_Id = ALTB.Account_Id
INNER JOIN dbo.account A
ON T.Account_Id = A.Account_Id
GROUP BY A.Account_Type, T.Bank, YEAR(T.Date), MONTH(T.Date)
 
-- Q1. What is the demographic profile of the bank's clients and how does it vary across districts?
SELECT D.Region, D.District_Name
,SUM(CASE WHEN C.Sex = 'Male' THEN 1 ELSE 0 END) AS TotalMale
,SUM(CASE WHEN C.Sex = 'Female' THEN 1 ELSE 0 END) AS TotalFemale
,AVG(C.Age) AS 'AvgAge'
, AVG(D.Average_Salary) AS 'AvgSalary' 
FROM dbo.client C
INNER JOIN dbo.district D
ON C.District_Id = D.District_Code
GROUP BY D.Region, D.District_Name
ORDER BY 1,2


-- Q2. Who are the top 10 defaulters in terms of highest amount and which district are they from
SELECT TOP 10 L.Account_Id, D.District_Name,SUM(L.Amount) AS 'TotalAmtDue' 
FROM dbo.loan L
LEFT JOIN [dbo].[account] A
ON L.Account_Id = A.Account_Id
LEFT JOIN [dbo].[district] D
ON A.District_Id = D.District_Code
WHERE Status = 'Loan Not Paid'
GROUP BY L.Account_Id, D.District_Name
ORDER BY 3 DESC


-- Q3. How the banks have performed over the years. Give their detailed analysis year
-- The bank performance is determined by the Average Balance and Total Balance maintained by each bank every year
SELECT Bank, Transaction_Year, AVG(AvgBalance) AS 'AvgBalance', SUM(Total_Balance) AS 'TotalBalance' FROM dbo.Transaction_KPI
WHERE Bank IS NOT NULL
GROUP BY Bank, Transaction_Year
ORDER BY 3 DESC, 4 DESC


-- Q4. What are the most common types of accounts and how do they differ in terms of usage and profitability?
-- If the Avg Balance > 3.2M then the bank is profitable and then the bank will get 5% intrest on the total available balance
SELECT T.Transaction_Year, T.Account_Type, AVG(T.AvgBalance) AS 'AvgBalance' 
,CASE
	WHEN AVG(T.AvgBalance) >= 3200000 THEN 'Will get 5%'
	ELSE 'Will not get 5%'
END AS 'Profitability'
FROM dbo.Transaction_KPI T
GROUP BY T.Transaction_Year, T.Account_Type
ORDER BY 1


-- Q5. Which types of cards are most frequently used by the bank's clients?
-- The frequently used cards by the bank's client (By Most Frequently we mean the most amount withdrawn with Credit Card)
SELECT T.Bank, C.Type AS 'Card Type', SUM(T.Amount) AS 'Total Amount' 
FROM [dbo].[card] C
INNER JOIN [dbo].[disposition] D
ON C.Disp_Id = D.Disp_Id
LEFT JOIN [dbo].[client] CL
ON D.Client_Id = CL.Client_Id
LEFT JOIN [dbo].[transactions] T
ON D.Account_Id = T.Account_Id
WHERE T.Type = 'Withdrawal'
GROUP BY C.Type, T.Bank
ORDER BY 1, 3 DESC


-- Q6. What is the bank’s loan portfolio and how does it vary across client gender?
SELECT C.Sex, L.Status AS 'Loan Status', SUM(L.Amount) AS 'Loan Amount' 
FROM [dbo].[loan] L
INNER JOIN [dbo].[disposition] D
ON L.Account_Id = D.Account_Id
INNER JOIN [dbo].[client] C
ON D.Client_Id = C.Client_Id
GROUP BY C.Sex, L.Status
ORDER BY 2,1,3 DESC


-- Q7. What is the age group where all the banks clients lie under
-- 0 - 18 -> Minor
-- 18 - 30 -> Younger Generation    
-- 30 - 45 -> Middle Age
-- 45 - 60 -> Pre-Senior
-- 60 - 80 -> Senior
-- 80 - 100 -> Elderly
SELECT [Age Group], COUNT(*) AS 'Total Clients'
FROM
	(SELECT 
	CASE 
		WHEN Age >= 0 AND Age < 18 THEN 'Minor'
		WHEN Age >= 18 AND Age < 30 THEN 'Younger Generation'
		WHEN Age >= 30 AND Age < 45 THEN 'Middle Age'
		WHEN Age >= 45 AND Age < 60 THEN 'Pre-Senior'
		WHEN Age >= 60 AND Age < 80 THEN 'Senior'
		WHEN Age >= 80 AND Age <= 100 THEN 'Elderly'
		ELSE 'Invalid Age'
	END AS 'Age Group'
	FROM [dbo].[client]) AS AgeGrpData
GROUP BY [Age Group]
ORDER BY [Age Group]