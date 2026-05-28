with base_data as
(
select
order_payment_type,
parse_date('%Y%m%d', cast(seller_oms_completed_date_key as string)) as completed_date,
parse_date('%Y%m%d', cast(seller_oms_payment_approved_date_key as string)) as approved_date
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and seller_oms_payment_approved_date_key is not null
and seller_oms_completed_date_key is not null
and seller_oms_completed_date_key > seller_oms_payment_approved_date_key
),
date_calc as
(
select
order_payment_type,
date_diff(completed_date, approved_date, DAY)*24 as settlement_hrs
from base_data
)
select
order_payment_type,
count(*) as total_volume,
round(avg(settlement_hrs),2) as avg_settlement_hrs,
--PERCENTILE_CONT(settlement_hrs , 0.9) over (partition by order_payment_type) as p90_settlement_hrs
APPROX_QUANTILES(settlement_hrs, 100)[OFFSET(90)] AS p90_settlement_hrs
from date_calc
group by 1
