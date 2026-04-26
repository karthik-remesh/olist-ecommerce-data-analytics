WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_seq
    FROM olist_orders o
    JOIN olist_customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_orders AS (
    SELECT
        customer_unique_id,
        DATE_TRUNC('month', order_purchase_timestamp) AS cohort_month
    FROM customer_orders
    WHERE order_seq = 1
),
returning_customers AS (
    SELECT DISTINCT customer_unique_id
    FROM customer_orders
    WHERE order_seq = 2
)
SELECT
    f.cohort_month,
    COUNT(f.customer_unique_id) AS total_customers,
    COUNT(r.customer_unique_id) AS retained_customers,
    ROUND(
        COUNT(r.customer_unique_id) * 100.0 / COUNT(f.customer_unique_id),
        2
    ) AS retention_rate_pct
FROM first_orders f
LEFT JOIN returning_customers r ON f.customer_unique_id = r.customer_unique_id
GROUP BY 1
ORDER BY 1;