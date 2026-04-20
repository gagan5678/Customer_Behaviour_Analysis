-- 1. To analyze how revenue is distributed across customers and identify whether a small group 
-- contributes to the majority of revenue.

WITH customer_revenue AS (
    SELECT 
        customer_id,
        SUM(purchase_amount) AS total_spent
    FROM customer_behaviour_analysis
    GROUP BY customer_id
),

ranked AS (
    SELECT 
        customer_id,
        total_spent,
        SUM(total_spent) OVER (ORDER BY total_spent DESC) AS cumulative_revenue,
        SUM(total_spent) OVER () AS total_revenue
    FROM customer_revenue
),

flagged AS (
    SELECT *,
        (cumulative_revenue / total_revenue) AS cum_pct
    FROM ranked
)

SELECT 
    COUNT(*) AS customers_contributing_80_percent,
    (SELECT COUNT(DISTINCT customer_id) FROM customer_behaviour_analysis) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM customer_behaviour_analysis), 
    2) AS percentage_customers
FROM flagged
WHERE cum_pct <= 0.8;

-- 2. To analyze how discount application impacts customer purchasing behavior in terms 
-- of order volume and average purchase value. 

SELECT 
    discount_applied,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_behaviour_analysis
GROUP BY discount_applied;

-- 3. To analyze how different age groups contribute to overall revenue and identify
--  high-value customer segments

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS age_group,

    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,ROUND(SUM(purchase_amount) * 100.0 
    / SUM(SUM(purchase_amount)) OVER (), 2) AS revenue_percentage
FROM customer_behaviour_analysis
GROUP BY age_group
ORDER BY total_revenue DESC;

-- 4. To analyze how different shipping types influence customer purchasing 
-- behavior and revenue generation.

SELECT 
    shipping_type,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_behaviour_analysis
GROUP BY shipping_type
ORDER BY total_revenue DESC;

-- 5. To analyze which product categories contribute the most to revenue and identify 
-- high-performing and low-performing segments

SELECT 
    category, 
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(
        SUM(purchase_amount) * 100.0 
        / SUM(SUM(purchase_amount)) OVER (), 
    2) AS revenue_percentage

FROM customer_behaviour_analysis
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 5;

-- 6. To analyze how frequently customers make purchases and identify the proportion 
-- of repeat vs one-time buyers.

WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(*) AS order_count
    FROM customer_behaviour_analysis
    GROUP BY customer_id
)

SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time Customers'
        ELSE 'Repeat Customers'
    END AS customer_type,
    
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage

FROM customer_orders
GROUP BY customer_type;

