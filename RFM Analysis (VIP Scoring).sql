with raw_data as
(
select
account_id,
date_diff(current_date(), date(max(order_created_at)), DAY) as days_since_last_order,
count(DISTINCT order_external_id )as total_orders,
sum(gmv) as total_gmv
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_created_at) >= '2026-01-01'
group by 1
),

rfm_scores as
(
select *,
NTILE(5) over (order by days_since_last_order) as r_score,
NTILE(5) over (order by total_orders) as f_score,
NTILE(5) over (order by total_gmv) as m_score
from raw_data
)
select
account_id,
r_score,
f_score,
m_score,
(r_score + f_score + m_score) as total_rfm_score,
case when r_score >= 4 and f_score >= 4 then 'VIP / Champions'
	when r_score >=4 and f_score >=3 then 'Loyal_Customers'
	when r_score <=2 and f_score >=4 then 'Risk'
	when r_score <=1 then 'Lost'
	else 'GENERAL'
	end as customer_summary,
	total_gmv,
	total_orders
	days_since_last_order
	from rfm_scores 
	order by total_rfm_score DESC
