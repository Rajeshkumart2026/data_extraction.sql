SELECT 
    account_id,
    COUNT(DISTINCT is_shopsy_order) as platforms_used,
    AVG(CASE WHEN is_shopsy_order = 'true' THEN gmv END) as shopsy_gmv,
    AVG(CASE WHEN is_shopsy_order = 'false' THEN gmv END) as mainline_gmv
FROM `your_table`
GROUP BY 1
HAVING platforms_used > 1;
