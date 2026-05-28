with incident_flag as
(
select
incident_id,
extract(MONTH from incident_creation_time) as Month,
issue_type,
sub_issue_type,
pain_in_mins,
case when proactive_flag = TRUE then 1 else 0 end as is_formal,
case when (proactive_flag = FALSE or proactive_flag is null) and pain_in_mins > 2880 then 1 else 0 end as hidden_rate,
case when lower(resolution_deadline_breached) = 'breach' then 1 else 0 end as breached_flag
from bigfoot_external_neo.mp_cs__ims_incident_hive_fact 
where date(incident_creation_time) >= '2026-01-01'
and incident_creation_time is not null
)

select
MONTH,
issue_type,
sub_issue_type,
count(Distinct incident_id) as total_incident,
round(avg(hidden_rate),1) as avg_hidden_pct,
round(avg(breached_flag),1) as avg_breached_pct,
round(corr(hidden_rate, breached_flag),3) as hidden_breach_corr
from incident_flag
group by 1,2,3


