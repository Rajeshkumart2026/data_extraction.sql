With first_order as
(
select
account_id,
order_date_time,
promise_breach,
row_number() over (partition by account_id order by order_date_time ) as order_rank
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and order_date_time is not null
and cast(new_customer_flag as bool) = true
),
retention_check as
(
select
f.account_id,
f.promise_breach,
exists( select 1  from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact s
	   where s.account_id = f.account_id
	   and s.order_date_time > f.order_date_time ) as has_returned
from first_order as f
where  f.order_rank = 1
group by 1,2,3
)

select
promise_breach,
count(account_id) as total_new_customers,
avg( case when has_returned   then 1 else 0 end) * 100 as retention_pct
from retention_check
group by 1
