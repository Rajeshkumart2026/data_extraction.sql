with base_data as
(
select
order_payment_type,
extract(YEAR from order_date_time) as order_year,
parse_date('%Y%m%d', cast(seller_oms_completed_date_key as string)) as completed_date,
parse_date('%Y%m%d', cast(seller_oms_payment_approved_date_key as string)) as approved_date
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2021-01-01'
and seller_oms_payment_approved_date_key is not null
and seller_oms_completed_date_key is not null
and seller_oms_completed_date_key > seller_oms_payment_approved_date_key
),
date_calc as
(
select
order_payment_type,
order_year,
date_diff(completed_date, approved_date, DAY)*24 as settlement_hrs
from base_data
)

select
order_payment_type,
round(avg(case when order_year = 2025 then settlement_hrs end),1) as avg_hrs_2025,
APPROX_QUANTILES(case when order_year = 2025 then settlement_hrs end, 100)[offset(90)] as p90_hrs_2025,
round(avg(case when order_year = 2026 then settlement_hrs end), 1) as avg_hrs_2026,
APPROX_QUANTILES(case when order_year = 2026 then settlement_hrs end, 100)[offset(90)] as p90_hrs_2026,
round(
	avg(case when order_year =2025 then settlement_hrs end) -
	avg(case when order_year = 2026 then settlement_hrs end),2) as yoy_avg_delta_hrs
from date_calc
group by 1
order by yoy_avg_delta_hrs


