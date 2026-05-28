with master_data as 
(
select 
account_id,
(listing_price - coalesce(promotion_discount_adjustment,0)- coalesce(bank_offer_adjustment,0)) as net_value,
date( order_date_time) as order_date,
from  bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and status not in ('CANCELLED', 'RETURNED')
),
rfm_raw as
(
  select
account_id,
count(*) as frequency,
min(order_date) as first_purchase,
max(order_date) as last_purchase,
avg(net_value) as monetary_value
from master_data
group by 1
)
select
account_id,
(frequency -1) as frequency,
date_diff(last_purchase, first_purchase, DAY) as recency,
date_diff(current_date(), first_purchase) as T,
monetary_value
from rfm_raw
where date_diff(current_date(), first_purchase, DAY) >0
