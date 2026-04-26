SELECT
    'missing_payment' AS issue_type,
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM olist_orders o
LEFT JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE p.order_id IS NULL
  AND o.order_status NOT IN ('canceled', 'unavailable');

-- Check 2: Orders where payment value deviates significantly from item total
WITH order_totals AS (
    SELECT
        order_id,
        ROUND(SUM(price + freight_value)::NUMERIC, 2) AS item_total
    FROM olist_order_items
    GROUP BY order_id
),
payment_totals AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value)::NUMERIC, 2) AS payment_total
    FROM olist_order_payments
    GROUP BY order_id
)
SELECT
    ot.order_id,
    ot.item_total,
    pt.payment_total,
    ROUND((pt.payment_total - ot.item_total)::NUMERIC, 2) AS discrepancy
FROM order_totals ot
JOIN payment_totals pt ON ot.order_id = pt.order_id
WHERE ABS(pt.payment_total - ot.item_total) > 1.0
ORDER BY ABS(pt.payment_total - ot.item_total) DESC;