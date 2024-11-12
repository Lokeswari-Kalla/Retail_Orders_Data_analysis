--Retrieve the first 50 rows from the orders table
SELECT TOP 50 * FROM df_orders;


--Retrieve detailed information about the df_orders table
EXEC sp_help 'df_orders';


-- The columns are having more data size like varchar(max) instead of varchar(20) and bigint instead of int. 
-- This query alters the column data types and sizes to optimize the storage.

-- Ensure order_id is NOT NULL
ALTER TABLE df_orders
ALTER COLUMN order_id INT NOT NULL;
Go
-- Add Primary Key Constraint
ALTER TABLE df_orders
ADD CONSTRAINT PK_df_orders PRIMARY KEY (order_id);
Go
ALTER TABLE df_orders
ALTER COLUMN order_date DATE;
GO
ALTER TABLE df_orders
ALTER COLUMN ship_mode VARCHAR(20);
GO
ALTER TABLE df_orders
ALTER COLUMN segment VARCHAR(20);
GO
ALTER TABLE df_orders
ALTER COLUMN country VARCHAR(20); 
GO
ALTER TABLE df_orders
ALTER COLUMN city VARCHAR(20);
GO
ALTER TABLE df_orders
ALTER COLUMN state VARCHAR(20);
GO
alter table df_orders
alter column discount decimal(7,2);
Go
alter table df_orders
alter column sale_price decimal(7,2);
Go
alter table df_orders
alter column profit decimal(7,2);
Go
ALTER TABLE df_orders
ALTER COLUMN postal_code VARCHAR(20);
GO
ALTER TABLE df_orders
ALTER COLUMN region VARCHAR(20);
GO
ALTER TABLE df_orders
ALTER COLUMN category VARCHAR(20);
GO
ALTER TABLE df_orders
ALTER COLUMN sub_category VARCHAR(20);
GO
ALTER TABLE df_orders
ALTER COLUMN product_id VARCHAR(50);
GO
ALTER TABLE df_orders
ALTER COLUMN quantity INT;
GO
ALTER TABLE df_orders
ALTER COLUMN discount DECIMAL(7,2);
GO
ALTER TABLE df_orders
ALTER COLUMN sale_price DECIMAL(7,2);
GO
ALTER TABLE df_orders
ALTER COLUMN profit DECIMAL(7,2);
GO


--Retrieve detailed information about the df_orders table
EXEC sp_help 'df_orders';


--find top 10 highest reveue generating products
SELECT TOP 10 
    product_id, 
    SUM(sale_price) AS total_revenue
FROM 
    df_orders
GROUP BY 
    product_id
ORDER BY 
    total_revenue DESC;


--find top 5 highest selling products in each region
WITH cte AS (
	SELECT
		region,product_id,sum(sale_price) as sale
	FROM
		df_orders
	GROUP BY
		region, product_id )
SELECT * FROM (
	SELECT *
		, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sale DESC) AS rank
	from cte) A
where rank<=5


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
	SELECT
		YEAR(order_date) AS order_year,MONTH(order_date) AS order_month,
		SUM(sale_price) AS sales
	FROM df_orders
	GROUP BY YEAR(order_date),MONTH(order_date)	)
SELECT 
	order_month,
	SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
	sum(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte 
GROUP BY
	order_month
ORDER BY
	order_month


-- For each category, which month had the highest sales
WITH CTE AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM 
        df_orders
    GROUP BY 
        category, FORMAT(order_date, 'yyyyMM'))
SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
    FROM 
        CTE) a
WHERE rn = 1;


-- Which sub-category had the highest growth by profit in 2023 compared to 2022
WITH CTE AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM 
        df_orders
    GROUP BY 
        sub_category, YEAR(order_date)),
CTE2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM 
        CTE 
    GROUP BY 
        sub_category)
SELECT TOP 1 
    *,
    (sales_2023 - sales_2022) AS growth
FROM 
    CTE2
ORDER BY 
    growth DESC;
