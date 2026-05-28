with sales_data as
(
select
city_tier,
is_large,
case when bank_offer_adjustment > 0 then 'Bank_Offer_Used' else 'No_Offer' end as offer_segment,
avg(gmv) as average_order_value,
sum(gmv) as total_revenue,
count(distinct order_item_id) as order_count
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and order_date_time is not null
group by 1,2,3
)
select
city_tier,
is_large,
offer_segment,
average_order_value,
total_revenue,
order_count
from sales_data
where is_large = 1



