
select
analytic_category,
round(avg(timestamp_diff(cast(initial_promise_date_time as timestamp),cast(order_created_at as timestamp), HOUR)),2) as avg_promised_hrs,
round(avg(timestamp_diff(cast(deliver_date_time as timestamp), cast(order_created_at as timestamp), HOUR)),2) as avg_actual_hrs,
round(avg(timestamp_diff(cast(initial_promise_date_time as timestamp), cast(deliver_date_time as timestamp), HOUR)),2) as avg_safety_buffer_hrs,
count(case when promise_breach = 'Breach' then 1 end)* 100 /count(*) as breach_rate_pct
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where deliver_date_time is not null
group by 1
having count(*) > 20
order by breach_rate_pct


