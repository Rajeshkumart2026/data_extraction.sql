with deduplicated_orders as
(
select
analytic_category as category,
seller_id,
city_tier,
is_large,
gmv,
(abs(order_item_unit_discount) + abs(promotion_discount_adjustment)) as bank_discount,
case when is_large = 1 then 450 else 60 end as logistics_cost
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
qualify row_number() over(partition by order_id order by order_date_time ASC) =1
),

be_logic as
(
select *,
greatest(0.1, safe_divide(gmv - bank_discount, gmv)) as net_rev_factor,
safe_divide(logistics_cost, (0.985 * greatest(0.1, safe_divide(gmv - bank_discount, gmv)))) as be_threshold
from deduplicated_orders
)

select
category,
is_large,
city_tier,
count(*) as total_orders,
round(avg(gmv),2) as avg_selling_price,
round(avg(be_threshold),2) as avg_be_threshold,
round(avg(case when gmv < be_threshold then 1 else 0 end) *100, 2) as at_risk_pct,
round(sum(case when gmv < be_threshold then (gmv - be_threshold) else 0 end),2) as total_cash_leakage
from be_logic
group by 1,2,3
having total_cash_leakage > 0 
order by total_cash_leakage DESC 
