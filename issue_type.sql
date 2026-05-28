select
extract(Month from incident_creation_time) as Month,
issue_type,
sub_issue_type,
count(DISTINCT incident_id) as total_incidents,
round(avg(timestamp_diff(cast(first_cust_contact_time as timestamp), cast(incident_creation_time as timestamp), MINUTE)),1) as avg_min_to_respond,
round(avg(timestamp_diff(cast(incident_first_solved_time as timestamp), cast(first_cust_contact_time as timestamp), HOUR)),1) as avg_time_to_solve,
round(avg(pain_in_mins),1) as avg_pain_min,
round(count(case when escalation_flag = TRUE then 1 end) * 100.0 / nullif(count(*),0),2) as excalation_pct
from bigfoot_external_neo.mp_cs__ims_incident_hive_fact 
where date(incident_creation_time) >= '2026-01-01'
and incident_creation_time is not null
and first_cust_contact_time is not null
group by 1,2,3
limit 100
