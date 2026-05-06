create database pizza_sales;

-- ============================================================
-- TASK: Verify database setup
-- PURPOSE: Confirm all 4 tables loaded correctly with expected row counts
-- ============================================================
SELECT 'orders'        AS tbl, COUNT(*) AS total_rows FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL
SELECT 'pizzas',        COUNT(*) FROM pizzas
UNION ALL
SELECT 'pizza_types',   COUNT(*) FROM pizza_types;

-- ============================================================
-- TASK: Explore raw data
-- PURPOSE: Understand what the data looks like before analysing

-- ============================================================

-- Step 1: Look at orders
SELECT * FROM orders LIMIT 5;

-- Step 2: Look at order_details
SELECT * FROM order_details LIMIT 5;

-- Step 3: Look at pizzas
SELECT * FROM pizzas LIMIT 5;

-- Step 4: Look at pizza_types
SELECT * FROM pizza_types LIMIT 5;

-- ============================================================
-- TASK: Data Quality Check
-- PURPOSE: Identify nulls, duplicates, and anomalies before
--          any analysis. Dirty data = wrong insights = bad decisions
-- ============================================================

-- Step 1: Check for NULLs in orders
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END)     AS null_date,
    SUM(CASE WHEN time IS NULL THEN 1 ELSE 0 END)     AS null_time
FROM orders;

-- Step 2: Check for NULLs in order_details
SELECT
    SUM(CASE WHEN order_details_id IS NULL THEN 1 ELSE 0 END) AS null_detail_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)         AS null_order_id,
    SUM(CASE WHEN pizza_id IS NULL THEN 1 ELSE 0 END)         AS null_pizza_id,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END)         AS null_quantity
FROM order_details;

-- Step 3: Check for NULLs in pizzas
SELECT
    SUM(CASE WHEN pizza_id IS NULL THEN 1 ELSE 0 END)      AS null_pizza_id,
    SUM(CASE WHEN pizza_type_id IS NULL THEN 1 ELSE 0 END) AS null_type_id,
    SUM(CASE WHEN size IS NULL THEN 1 ELSE 0 END)          AS null_size,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END)         AS null_price
FROM pizzas;

-- Step 4: Check for duplicates in orders
SELECT order_id, COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Step 5: Check quantity makes sense
SELECT MIN(quantity) AS min_qty, 
       MAX(quantity) AS max_qty
FROM order_details;

-- ============================================================
-- TASK: Check date range and pizza categories
-- PURPOSE: Confirm we have a full year of data and understand
--          what product categories exist in the business
-- ============================================================

-- Step 1: What time period does our data cover?
SELECT 
    MIN(date) AS first_order,
    MAX(date) AS last_order,
    COUNT(DISTINCT date) AS total_days
FROM orders;

-- Step 2: What pizza categories exist?
SELECT DISTINCT category, COUNT(*) AS pizza_count
FROM pizza_types
GROUP BY category
ORDER BY pizza_count DESC;

-- -- ============================================================
-- TASK: Peak Hours Analysis
-- PURPOSE: Identify the busiest hours of the day to help
--          management schedule staff efficiently
-- ============================================================
SELECT 
    HOUR(time)       AS hour_of_day,
    COUNT(*)       AS total_orders   
FROM orders
GROUP BY  HOUR(time)                            
ORDER BY total_orders DESC;

-- ============================================================
-- TASK: Busiest Days of the Week Analysis
-- PURPOSE: Identify which days drive the most orders to help
--          management plan staffing and promotions accordingly
-- ============================================================

SELECT      dayname(date)       AS day_of_week,     COUNT(*)       AS total_orders    FROM orders GROUP BY  dayname(date)                           ORDER BY total_orders DESC;

-- ============================================================
-- TASK: Total Revenue for 2015
-- PURPOSE: Understand how much money the business made in total
--          for the year — the most fundamental business metric
-- ============================================================
SELECT 
    SUM(quantity * price)  AS total_revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- ============================================================
-- TASK: Monthly Revenue Trend
-- PURPOSE: Break down total revenue by month to identify
--          seasonality and peak sales periods in 2015
-- DIFFICULTY: Intermediate
-- ============================================================
SELECT 
    MONTH(o.date)         AS month,
    SUM(od.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p         ON od.pizza_id = p.pizza_id
GROUP BY MONTH(o.date)
ORDER BY month;

-- ============================================================
-- TASK: Top 5 Bestselling Pizzas by Quantity and worst
-- PURPOSE: Identify which pizzas customers love most to inform
--          menu decisions, promotions and stock planning
-- DIFFICULTY: Intermediate
-- ============================================================

SELECT 
    pt.name              AS pizza_name,
    SUM(od.quantity)          AS total_quantity
FROM order_details od
JOIN pizzas p     ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p. pizza_type_id= pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

SELECT 
    pt.name              AS pizza_name,
    SUM(od.quantity)          AS total_quantity
FROM order_details od
JOIN pizzas p     ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p. pizza_type_id= pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity asc
LIMIT 5;

-- ============================================================
-- TASK: Revenue by Pizza Category
-- PURPOSE: Identify which pizza category generates the most
--          revenue to inform menu strategy and marketing focus
-- DIFFICULTY: Intermediate
-- ============================================================

SELECT 
    category              AS best_category,
   round (SUM(quantity * price), 2)          AS revenue
FROM order_details od
JOIN pizzas p     ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p. pizza_type_id= pt.pizza_type_id
GROUP BY category
ORDER BY revenue desc
;

-- ============================================================
-- TASK: Master Query for Power BI
-- PURPOSE: Combine all 4 tables into one clean dataset ready
--          for Power BI dashboard — analysts call this a master
--          query or a flat table
-- DIFFICULTY: Intermediate
-- ============================================================
SELECT 
    o.order_id,
    o.date,
    o.time,
    pt.name        AS pizza_name,
    pt.category,
    p.size,
    od.quantity,
    p.price,
    od.quantity * p.price AS revenue
FROM orders o
JOIN order_details od ON o.order_id    = od.order_id
JOIN pizzas p         ON od.pizza_id   = p.pizza_id
JOIN pizza_types pt   ON p.pizza_type_id = pt.pizza_type_id;


-- ============================================================
-- TASK: Fix date column data type
-- PURPOSE: Ensure date is stored as proper DATE type in MySQL
--          so Power BI recognises it correctly when connecting
-- DIFFICULTY: Beginner
-- ============================================================
ALTER TABLE orders 
MODIFY COLUMN date DATE;