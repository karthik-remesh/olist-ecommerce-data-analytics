SELECT
    c.customer_state,
    COUNT(o.order_id) AS total_orders,
    SUM(
        CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS late_deliveries,
    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(o.order_id),
        2
    ) AS late_delivery_pct,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date - o.order_purchase_timestamp
            )) / 86400
        )::NUMERIC,
        1
    ) AS avg_delivery_days
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(o.order_id) >= 50
ORDER BY late_delivery_pct DESC;