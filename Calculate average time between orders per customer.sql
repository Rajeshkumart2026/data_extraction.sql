with cummulative_data as
(
select
customer_id,
order_date as first_date
lag(order_date) over (partition by customer_id order by order_date) as prev_date
from orders 
)
select
customer_id,
avg(date_diff(first_date, prev_date,DAY)) as avg_days
from cummulative_data
where prev_date is not null
group by 1
