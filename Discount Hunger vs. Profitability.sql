select
extract(Month from incident_creation_time) as Month,
issue_type,
sub_issue_type,
count(*) as total_orders,
round(count( case when proactive_flag = TRUE then 1 end) / nullif(count(*),0),2) as escalation_pct,
round(count(case when (proactive_flag = FALSE or proactive_flag is null) and pain_in_mins > 2880 then
1 end) / nullif(count(*),0),2) as hidden_escalation_pct,
round((count(case when (proactive_flag = FALSE or proactive_flag is null) 
and pain_in_mins >= 2880 then 1 end)* 100 - 
count( case when proactive_flag = TRUE then 1 else 0 end)),2) as silent_pain_gap
from bigfoot_external_neo.mp_cs__ims_incident_hive_fact 
where date(incident_creation_time) >= '2026-01-01'
group by 1,2,3
order by Month, hidden_escalation_pct
