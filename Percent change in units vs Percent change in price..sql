WITH price_changes AS (
    SELECT 
        product_id,
        listing_price,
        units,
        LAG(listing_price) OVER (PARTITION BY product_id ORDER BY order_date_time) as prev_price,
        LAG(units) OVER (PARTITION BY product_id ORDER BY order_date_time) as prev_units
    FROM `your_table`
)
SELECT 
    product_id,
    SAFE_DIVIDE((units - prev_units)/prev_units, (listing_price - prev_price)/prev_price) as elasticity
FROM price_changes
WHERE prev_price IS NOT NULL AND prev_price != listing_price;
