with ranked_order as
(
select
account_id,
promise_breach,
row_number() over (partition by account_id order by order_date_time  asc) as order_rank
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and order_date_time is not null
),

user_journey as
(
select
account_id,
max(case when order_rank = 1 then promise_breach end) as breach_order_1,
max(case when order_rank = 2 then 1 else 0 end) as order_made_2,

max(case when order_rank = 2 then promise_breach end ) as breach_order_2,
max(case when order_rank = 3 then 1 else 0 end) as order_made_3
from ranked_order
group by account_id
),

labelled_scenario as
(
select *,
case 
	when breach_order_1 = 'Breach' then 'Breach on 1 order'
	when breach_order_1 != 'Breach' and order_made_2 = 1 and breach_order_2 = 'Breach' then 'Breach on 2nd Order'
	else 'Others'
	end as scenario_group
	from user_journey
	)

select 
scenario_group,
count(*) as sample_size,
avg( case when scenario_group = 'Breach on 1 order'  then order_made_2
		  when scenario_group =  'Breach on 2nd Order' then order_made_3 end) * 100 as retention_pct
from labelled_scenario
where scenario_group != 'Others'
group by 1
