select
analytic_category,
round(corr(cast(timestamp_diff(ready_to_ship_date_time, order_created_at, HOUR) as float64), case when lower(promise_breach) in ('yes','1','true') then 1.0 else 0.0 end),3) as seller_delay_correlation,
round(corr(cast(timestamp_diff(deliver_date_time, ship_date_time, HOUR) as float64), case when lower(promise_breach) in ('yes', '1', 'true') then 1.0 else 0.0 end),3) as transit_delay_correlation
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01' 
and deliver_date_time is not null
and ready_to_ship_date_time is not null
group by 1
having count(*) > 10
order by seller_delay_correlation DESC
