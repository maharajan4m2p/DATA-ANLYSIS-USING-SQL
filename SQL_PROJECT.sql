--BEFORE PULL THE DATA WE NEED TO CREATE THE TABLE
CREATE TABLE sales(
	transaction_id VARCHAR(15),
	customer_id VARCHAR(15),
	customer_name VARCHAR(30),
	customer_age INT,
	gender VARCHAR(15),
	product_id VARCHAR(15),
	product_name VARCHAR(15),
	product_category VARCHAR(15),
	quantiy INT,
	prce FLOAT,
	payment_mode VARCHAR(15),
	purchase_date DATE,
	time_of_purchase TIME,
	status VARCHAR(15),
)

SELECT * FROM sales

--PULL THE  DATA FROM EXCEL
--TO CHANGE THE DATE FORMAT WHILE IN EXECL IT IS DAY/MONTH/YEAR TO YER/MONTH/DAY 
SET DATEFORMAT dmy
BULK INSERT sales
FROM'C:\Users\acer\Downloads\sales.csv'
WITH(
	FIRSTROW=2,
	FIELDTERMINATOR=',',
	ROWTERMINATOR='\n'
)

SELECT * FROM sales

--DATA CLEANING
--1) TO CHECK THE DUPLICATES

SELECT * FROM sales

SELECT transaction_id
FROM sales
GROUP BY transaction_id
HAVING COUNT(transaction_id) >1

WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION  BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales

)


DELETE FROM CTE 
WHERE Row_Num>1

SELECT * FROM sales

--2)CHECK THE DATATYPE

SELECT COLUMN_NAME , DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales'

--3) CHECK NULL VALUES
--TO CHECK NULL COUNT

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    CAST('SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + ' 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL' AS NVARCHAR(MAX)), 
    ' UNION ALL '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales' 
  AND TABLE_SCHEMA = 'dbo'; -- Change 'dbo' if your schema is different

-- Execute the generated SQL
EXEC sp_executesql @SQL;

--TREATING THE NULL 
--USED TO FIND THE NULL VALUE

SELECT *
FROM sales
WHERE transaction_id IS null 
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR
product_category IS NULL
OR
product_name IS NULL
OR
quantiy IS NULL
OR
prce IS NULL
OR
payment_mode IS NULL
OR
purchase_date IS NULL
OR
time_of_purchase IS NULL
OR
status IS NULL

--DELETE THE transaction_id IS NULL 


DELETE FROM sales
WHERE transaction_id IS NULL

--FIND THE NULL 

SELECT * FROM sales
WHERE customer_name ='Ehsaan Ram'

--FILL THE NULL USING UPDATE ALL THE NULL VALUES IN DATA
UPDATE sales
SET customer_id='CUST9494'
WHERE transaction_id='TXN977900'

SELECT * FROM sales
WHERE customer_name ='Damini Raju'
UPDATE sales
SET customer_id='CUST1401'
WHERE transaction_id='TXN985663'


SELECT * FROM sales
WHERE customer_id ='CUST1003'

UPDATE sales
SET customer_name='Mahika Saini',customer_age='35',gender='M'
WHERE transaction_id='TXN432798'


SELECT * FROM sales

--DATA CLEANING TO UPDATE'F'FOR FEMALE AND'M'FOR MALE

SELECT DISTINCT gender
FROM sales

UPDATE sales
SET gender='M'
WHERE gender='MALE'

UPDATE sales
SET gender='F'
WHERE gender='FEMALE'

---CLEANING THE PAYMENT MODE CC TO Credit Card

SELECT DISTINCT payment_mode
FROM sales

UPDATE sales
SET payment_mode='Credit Card'
WHERE payment_mode='CC'

SELECT * FROM sales

--DATA ANALYSIS

-- TOP 5 MOST SELLING PRODUCT BY QUANTITY

SELECT * FROM sales
SELECT DISTINCT status
FROM sales

SELECT TOP 5 product_name , SUM(quantiy) AS total_quanitity_sold
FROM sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY total_quanitity_sold DESC

-- frequently cancelled product 

SELECT TOP 5 product_name , COUNT(*) AS total_cancelled
FROM sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC

--what time of the day hieghest purchase

SELECT * FROM sales

SELECT 
	CASE
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 0 AND 5 THEN 'NIGTH'
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 18 AND 23 THEN 'EVENING'
	END AS time_of_day,
	COUNT(*) AS total_orders
FROM sales
GROUP BY 
	CASE
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 0 AND 5 THEN 'NIGTH'
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR,time_of_purchase)  BETWEEN 18 AND 23 THEN 'EVENING'
	END 
ORDER BY total_orders DESC

--TOP 5 HIGH SOPEDING CUSTOMER


SELECT * FROM sales

SELECT TOP 5 customer_name,
FORMAT( SUM(prce*quantiy),'C0','en-IN')AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(prce*quantiy)DESC

--WHICH PRODUCT CATEGORIES GENERATE HIGHEST REVENUE

SELECT * FROM sales

SELECT product_category,
FORMAT( SUM(prce*quantiy),'C0','en-IN')AS Revenue
FROM sales
GROUP BY product_category
ORDER BY SUM(prce*quantiy) DESC

--RETURN / CANCELLATION RATE PER CATEGORY 

SELECT * FROM sales

--CANCELATION
SELECT product_category,
FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*),'N3')+'%' AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC

--RETURNPE
SELECT product_category,
FORMAT(COUNT(CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*),'N3')+'%' AS returned_percent
FROM sales
GROUP BY product_category
ORDER BY returned_percent DESC

--most preferred payment mode 

SELECT * FROM sales

SELECT payment_mode, COUNT (payment_mode) AS total_count 
FROM sales
GROUP BY payment_mode
ORDER BY total_count DESC

--AGR AFFECT PURCHASE BEHAVIOUR

SELECT * FROM sales
--SELECT MIN(customer_age) , MAX(customer_age) FROM sales


SELECT
	CASE
		WHEN customer_age  BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age  BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age  BETWEEN 36 AND 50 THEN '36-50'
		ELSE'51+'
		END AS customer_age,
	FORMAT(SUM(prce*quantiy),'C0','en-IN')AS total_purchase
FROM sales
GROUP BY 
	CASE
		WHEN customer_age  BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age  BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age  BETWEEN 36 AND 50 THEN '36-50'
		ELSE'51+'
	END
ORDER BY total_purchase DESC


--MONTHLY SALES TRENDS

SELECT * FROM sales

SELECT 
	FORMAT(purchase_date,'yyyy-MM') AS month_year,
	FORMAT(SUM(prce*quantiy),'C0','en-IN')AS total_sales,
	SUM(quantiy) AS total_quantity
FROM sales
GROUP BY FORMAT(purchase_date,'yyyy-MM')


--CERTION GENDER BUY MORE SPECIFIC CATEGORY 

SELECT * FROM sales

SELECT gender,product_category,COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY total_purchase DESC
