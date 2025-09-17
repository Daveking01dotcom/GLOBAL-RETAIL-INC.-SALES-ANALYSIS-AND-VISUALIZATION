------Create Table "Sales"


CREATE TABLE sales (
    transaction_no INT PRIMARY KEY,
    date DATE,
    product_no INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    quantity INT,
    customer_no INT,
    country VARCHAR(50)
);
l

ALTER TABLE sales
ALTER COLUMN product_no TYPE VARCHAR(20);


DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    transaction_no VARCHAR(20),
    date DATE,
    product_no VARCHAR(20),
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    quantity INT,
    customer_no VARCHAR(20),
    country VARCHAR(50)
);



SELECT *
FROM sales


SELECT 
  transaction_no,
  TO_CHAR(date, 'DD/MM/YYYY') AS date,
  product_name,
  price
FROM sales;


------ Check for Missing Values-----

SELECT *
FROM sales
WHERE transaction_no IS NULL
  OR  date IS NULL
  OR product_no IS NULL
  OR product_name IS NULL
  OR price IS NULL
  OR  quantity IS NULL
  OR  customer_no IS NULL
  OR  country IS NULL;


-----Check for Duplicates

SELECT transaction_no, COUNT(*)
FROM sales
GROUP BY transaction_no
HAVING COUNT(*) > 1;


-----Check for Outliers

SELECT *
FROM sales
WHERE price < 0 OR price > 10000
   OR quantity < 0 OR quantity > 1000;


------DATA VALIDATION QUERIES

----Future Dates Check

CREATE VIEW sales_future_dates AS
SELECT *
FROM sales
WHERE date > CURRENT_DATE;


-----Blank or Improper Product Names

CREATE VIEW sales_blank_product_names AS
SELECT *
FROM sales
WHERE TRIM(product_name) = '';

----Country Name Format Issues

CREATE VIEW sales_country_format_issues AS
SELECT DISTINCT country
FROM sales
WHERE country ~ '[^a-zA-Z\s]';

----Revenue Consistent Check

CREATE VIEW sales_incorrect_revenue AS
SELECT *
FROM sales
WHERE revenue IS DISTINCT FROM price * quantity;


------CREATE DERIVED FIELDS
----REVENUE

ALTER TABLE sales
ADD COLUMN revenue DECIMAL(12, 2);

UPDATE sales
SET revenue = price * quantity;

SELECT *
FROM sales

----CUSTOMER TRANSACTION COUNT

CREATE VIEW customer_transaction_count AS 
SELECT customer_no, COUNT(*) AS total_transactions
FROM sales
GROUP BY customer_no;

---CHECK THE VIEW

SELECT * FROM customer_transaction_count
ORDER BY total_transactions DESC;


SELECT *
FROM sales

-----Create comprehensive SQL scripts to answer these business questions:
----Customer Analytics

----Top 20 customers by total revenue

SELECT customer_no, SUM(revenue) AS total_revenue
FROM sales
GROUP BY customer_no
ORDER BY total_revenue DESC
LIMIT 20;

----Customer purchase frequency distribution 

SELECT total_purchases, COUNT(*) AS customer_count
FROM (
    SELECT customer_no, COUNT(*) AS total_purchases
    FROM sales
    GROUP BY customer_no
) AS customer_freq
GROUP BY total_purchases
ORDER BY total_purchases;


----Product Performance Analysis 

---Best and Worst Performing Products by Revenue
 
-- Best Products
SELECT product_name, SUM(revenue) AS total_revenue
FROM sales
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Worst Products
SELECT product_name, SUM(revenue) AS total_revenue
FROM sales
GROUP BY product_name
ORDER BY total_revenue ASC
LIMIT 10;

----Products with the highest/lowest average transaction values 

-- Highest
SELECT product_name, AVG(revenue) AS avg_transaction_value
FROM sales
GROUP BY product_name
ORDER BY avg_transaction_value DESC
LIMIT 10;

-- Lowest
SELECT product_name, AVG(revenue) AS avg_transaction_value
FROM sales
GROUP BY product_name
ORDER BY avg_transaction_value ASC
LIMIT 10;


----Product performance trends over time 

SELECT
    DATE_TRUNC('month', date) AS month,
    product_name,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue
FROM sales
GROUP BY month, product_name
ORDER BY month, total_revenue DESC;


-----Sales Performance

----Yearly and quarterly sales trends 

-- Yearly
SELECT DATE_PART('year', date) AS year, SUM(revenue) AS total_revenue
FROM sales
GROUP BY year
ORDER BY year;

-- Quarterly
SELECT DATE_PART('year', date) AS year,
       DATE_PART('quarter', date) AS quarter,
       SUM(revenue) AS total_revenue
FROM sales
GROUP BY year, quarter
ORDER BY year, quarter;


---Running totals and moving averages 


-- Monthly running total and 3-month moving average
SELECT
    DATE_TRUNC('month', date) AS month,
    SUM(revenue) AS monthly_revenue,
    SUM(SUM(revenue)) OVER (ORDER BY DATE_TRUNC('month', date)) AS running_total,
    ROUND(AVG(SUM(revenue)) OVER (ORDER BY DATE_TRUNC('month', date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3_months
FROM sales
GROUP BY month
ORDER BY month;

----Geographic Analysis

--Country-wise sales performance ranking 

SELECT country, SUM(revenue) AS total_revenue,
       RANK() OVER (ORDER BY SUM(revenue) DESC) AS country_rank
FROM sales
GROUP BY country
ORDER BY country_rank;

--Market penetration analysis by country

SELECT country, COUNT(DISTINCT customer_no) AS unique_customers
FROM sales
GROUP BY country
ORDER BY unique_customers DESC;

CREATE VIEW total_revenue AS
SELECT
    SUM(Revenue) AS total_sales,
    SUM(Quantity) AS total_quantity_sold
FROM sales;

SELECT * FROM public.total_revenue;


CREATE VIEW top_10_products AS
SELECT
    Product_name,
    SUM(Revenue) AS total_revenue
FROM sales
GROUP BY Product_name
ORDER BY total_revenue DESC
LIMIT 10;

SELECT *
FROM public.top_10_products;