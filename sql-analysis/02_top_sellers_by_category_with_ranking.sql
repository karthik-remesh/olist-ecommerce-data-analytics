WITH seller_category_revenue AS (
    SELECT
        s.seller_id,
        t.string_field_1 AS category_english,
        ROUND(SUM(oi.price)::NUMERIC, 2) AS revenue
    FROM olist_order_items oi
    JOIN olist_sellers s ON oi.seller_id = s.seller_id
    JOIN olist_products p ON oi.product_id = p.product_id
    JOIN product_category_name_translation t
        ON p.product_category_name = t.string_field_0
    GROUP BY 1, 2
),
ranked_sellers AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY category_english
            ORDER BY revenue DESC
        ) AS rank_in_category
    FROM seller_category_revenue
)
SELECT *
FROM ranked_sellers
WHERE rank_in_category <= 3
ORDER BY category_english, rank_in_category;