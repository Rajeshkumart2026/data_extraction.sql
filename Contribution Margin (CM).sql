with sales_data as
(
select
city_tier,
is_large,
(abs(order_item_unit_discount) + abs(promotion_discount_adjustment)) as bank_offer_adjustment,
gmv,
order_id,
order_date_time
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and order_id is not null
Qualify row_number() over(partition by order_id order by order_date_time asc) =1
),

margin_cal as
(
select *,
(gmv - bank_offer_adjustment) as net_revenue,
case when is_large = 1 then 450 else 60 end as est_logistics_cost,
(gmv - bank_offer_adjustment ) * 0.015 as est_pg_fee
from sales_data
)

select
city_tier,
is_large,
case when bank_offer_adjustment > 0 then 'Bank_used_offer' else 'No_bank_offer' end as offer_segment,
count(Distinct order_id) as total_orders,
round(sum(net_revenue),2) as total_net_revenue,
round(sum(net_revenue - est_logistics_cost - est_pg_fee),0) as total_contribution_margin,
round(safe_divide(sum(net_revenue - est_logistics_cost - est_pg_fee), sum(gmv)) * 100, 2) as cm_pct_of_gmv
from margin_cal
group by 1,2,3
order by city_tier, is_large, total_contribution_margin

 

