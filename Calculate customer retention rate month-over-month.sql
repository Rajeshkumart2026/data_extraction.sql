with monthly_user as
(
select
distinct
date_trunc('Month', order_date) as month
customer_id
from orders
)
select
m1.month,
count(m2.customer_id)* 100 / count(m1.customer_id) as retention_pct
from monthly_user as m1 
join monthly_user as m2
on m1.customer_id = m2.customer_id
and m2.month = m1.month + interval '1 Month'
group by m1.customer_id
order by m1.month
