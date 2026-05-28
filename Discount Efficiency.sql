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
) 

select
city_tier,
is_large,
case when bank_offer_adjustment > 0 then 'Bank_offer' else 'No_offers' end as offer_segment,
count(distinct order_id) as total_orders,
sum(gmv) as total_revenue,
sum(bank_offer_adjustment) as bank_offer,
round(safe_divide(sum(bank_offer_adjustment), sum(gmv)),2) as bank_offer_gmv_pct,
avg(gmv - bank_offer_adjustment) as net_order_value
from sales_data
group by 1,2,3
 




