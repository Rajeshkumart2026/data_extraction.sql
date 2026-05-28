with user_first_purchase as
(
select
account_id,
data_trunc(min(unit_creation_date_time), Month) as cohort_month,
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
group by 1
),

user_activities as
(
select
t.account_id,
f.cohort_month,
data_trunc(t.order_date_time , Month) as activity_month,
date_diff(data_trunc(t.order_date_time, Month), f.cohort_month, Month) as month_number
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact as t 
join user_first_purchase as f
on t.account_id = f.account_id
)
select
cohort_month,
month_number,
count(Distinct account_id) as active_users
from user_activities
group by 1,2
