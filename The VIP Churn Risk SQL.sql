with rfm_base as
(
select
account_id,
count(DISTINCT order_external_id )as total_orders,
sum(gmv) as total_gmv,
NTILE(5) over(order by sum(gmv)) as m_score,
NTILE(5) over (order by COUNT(DISTINCT order_external_id)) as f_score 
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_created_at) >= '2025-01-01'
group by 1
),

last_order_service as
(
select
f.account_id,
f.order_external_id,
f.order_created_at,
f.promise_breach,
i.escalation_flag,
i.pain_in_mins,
row_number() over (partition by f.account_id order by f.order_created_at DESC) as recency_rank

from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact as f
left join bigfoot_external_neo.mp_cs__ims_incident_hive_fact i 
on f.order_external_id = i.order_external_id
where date(order_created_at) >= '2026-01-01'
)
select
r.account_id,
r.total_gmv,
r.total_orders,
l.order_external_id as last_order_id,
l.promise_breach as last_order_breach_status,
case when cast(l.escalation_flag as string) = '0' and l.pain_in_mins > 2880 then 'Yes' else 'No' end as was_last_order_hidden_escalation,
	
case 
	when (l.promise_breach = 'Breach' or l.pain_in_mins > 2880) and r.m_score > 4 then 'Critical'
	when (l.promise_breach = 'Breach' or l.pain_in_mins > 2880) and r.m_score < 4 then 'Std_Churn_Risk'
	else 'Healthy'
	end as churn_risk_priority
from rfm_base as r
join last_order_service l
on r.account_id = l.account_id
where l.recency_rank = 1
	and r.m_score >=4
	order by r.total_gmv DESC
