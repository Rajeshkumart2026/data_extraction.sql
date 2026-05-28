select
case 
when safe_divide((abs(coalesce(bank_offer_adjustment,0)) + abs(coalesce(promotion_discount_adjustment,0))), gmv) > 0.20 then 'High_Discount' 
	when safe_divide((abs(coalesce(bank_offer_adjustment,0)) + abs(coalesce(promotion_discount_adjustment,0))), gmv) between 0.05 and 0.2 then 'Moderate'
else 'Full_Price'
end as discount_segment,
count(distinct account_id) as total_orders,
avg(gmv) as avg_order_value,
sum(gmv) as total_revenue
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and upper(status) NOT IN ('CANCELLED', 'RETURNED')
group by 1
order by avg_order_value DESC

