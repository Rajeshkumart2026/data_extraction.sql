with customer_spantime as
(
select
customer_id,
date_trunc(min(order_date)) as cohort_month,
date_trunc(max(order_date)) as last_order_month
        from orders
group by customer_id
)
select
cohort_month,
avg(case when last_order_month < cohort_month + interval '3 Month' then 1 else 0 end) * 100
as churn_pct
from customer_spantime
group by cohort_month
order by cohort_month
