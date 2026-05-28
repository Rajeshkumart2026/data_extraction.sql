select
courier_name,
count(*) as total_orders,
round(avg(timestamp_diff(deliver_date_time, dispatch_date_time, HOUR)),1) as avg_last_mile_hrs,
APPROX_QUANTILES(timestamp_diff(deliver_date_time, dispatch_date_time, HOUR), 100)[offset(90)] as p90_last_mile_hrs,
round(CORR(timestamp_diff(deliver_date_time, dispatch_date_time, HOUR), 
	case when promise_breach = 'Breach' then 1 else 0 end ),2) as delay_to_breach_correlation
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
group by 1
Having total_orders > 100
order by avg_last_mile_hrs DESC
