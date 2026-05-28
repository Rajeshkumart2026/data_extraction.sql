with queue_audit as
(
select
current_queue_name,
incident_id,
pain_in_mins,
case when (proactive_flag = FALSE or proactive_flag is null) and pain_in_mins > 2880 then 1 else 0 end as is_hidden,
case when lower(resolution_deadline_breached) = 'breach' then 1 else 0 end as is_breach
from bigfoot_external_neo.mp_cs__ims_incident_hive_fact 
where date(incident_creation_time) >= '2026-01-01'
and incident_creation_time is not null
)
select
current_queue_name,
count(distinct incident_id) as total_incidents,
round(avg(is_breach),2) as breach_pct,
round(avg(is_hidden),2) as hidden_pct,
round(corr(is_hidden, is_breach),3) as queue_risk_correlation
from queue_audit
group by 1
having total_incidents > 100
order by queue_risk_correlation





