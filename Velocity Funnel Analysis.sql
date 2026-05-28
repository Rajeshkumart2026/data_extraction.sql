select
analytic_category,
avg(timestamp_diff(ready_to_ship_date_time, order_created_at, DAY)) as avg_hours_seller_processing,
avg(timestamp_diff(ship_date_time, ready_to_ship_date_time, DAY)) as avg_hours_pickup_wait,
avg(timestamp_diff(deliver_date_time, ship_date_time, DAY)) as avg_hours_in_transit,
avg(timestamp_diff(deliver_date_time, order_created_at, DAY)) as total_lead_time_hrs,
count(*) as total_units
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and deliver_date_time is not null
and deliver_date_time > ship_date_time
and ship_date_time > ready_to_ship_date_time
and ready_to_ship_date_time > order_created_at
group by 1
order by total_lead_time_hrs DESC
limit 100
