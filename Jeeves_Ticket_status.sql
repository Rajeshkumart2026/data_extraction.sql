with ticket_history as (
  select 
  case_id,
  updatedby,
 alloted_date,
 completed_date,
 status_date,
 --count_tic_status,
 Closure_same_day,
 closure_day_count,
  case when alloted_date is not null then 1 else 0 end as was_alloted,
 case when completed_date is not null then 1 else 0 end as was_completed,
 case when (alloted_date is not null and completed_date is not null)
	then date_diff(completed_date,alloted_date,DAY) else null
	end as days_alloted_difference
 from
(
select
case_id,
updatedby,
date(status_timestamp) as status_date,
min(case when (ticket_history_status) = 'ALLOCATED' then date(status_timestamp) end) as alloted_date,
min(case when (ticket_history_status) IN ('COMPLETED', 'CANCELLED') then date(status_timestamp) else null end) as completed_date,
ticket_history_status,
--ticket_history_sub_status,
--count(distinct(ticket_history_status)) as count_tic_status,
max(completed_update_timestamp)  as completed_ticket_date,
max(cancelled_update_timestamp) as cancelled_ticket_date,
case when date(max(completed_update_timestamp)) = Date(status_timestamp)
or date(max(cancelled_update_timestamp)) = Date(status_timestamp) then 'closed_same_day'
when max(completed_update_timestamp)  > Date(status_timestamp) 
	 or max(cancelled_update_timestamp) > Date(status_timestamp) 
then 'Not_same_day'
else 'Others'
end as Closure_same_day,
TIMESTAMP_diff(max(if(completed_update_timestamp is not null, completed_update_timestamp,
                   if(cancelled_update_timestamp is not null, cancelled_update_timestamp, null))),Date(status_timestamp), DAY) as closure_day_count,
 from(
select 
case_id,
status_timestamp,
allotted_date,
ticket_history_status,
ticket_history_sub_status,
allocated_entity,
appointment_date,
is_last_update,
engineer_name,
updatedby,
primary_issue,
secondary_issue,
set_delivered_status_date,
first_time_visit,
completed_update_timestamp,
cancelled_update_timestamp,
COUNT(CASE WHEN ticket_history_status = 'ALLOCATED' THEN 1 END) AS allocated_count,
 COUNT(CASE WHEN ticket_history_status = 'CANCEL_INITIATED' THEN 1 END) AS cancel_initiated_count,
 COUNT(CASE WHEN ticket_history_status = 'RESCHEDULED' THEN 1 END) AS rescheduled_count,
 COUNT(CASE WHEN ticket_history_status = 'REOPEN' THEN 1 END) AS reopen_count,
status_date
from bigfoot_external_neo.scp_jeeves__jeeves_ticket_history_fact
where DATE(status_timestamp) = '2025-07-01'
group by 
case_id,
status_timestamp,
allotted_date,
ticket_history_status,
ticket_history_sub_status,
allocated_entity,
appointment_date,
is_last_update,
engineer_name,
updatedby,
primary_issue,
secondary_issue,
set_delivered_status_date,
first_time_visit,
status_date,
completed_update_timestamp,
cancelled_update_timestamp
)as x
group by 
case_id,
updatedby,
status_timestamp,
ticket_history_status
--ticket_history_sub_status,

)y 
) 
select * from ticket_history 