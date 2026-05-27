with main_count as
(
select x.*,
countif(ticket_history_sub_status = 'ALLOCATED') as ALLOCATED_count,
countif(ticket_history_sub_status = 'TECHNICIAN_REACHED_SITE') as TECHNICIAN_REACHED_SITE_count,
countif(ticket_history_sub_status = 'RESCHEDULED') as RESCHEDULED_count,
countif(ticket_history_sub_status = 'CUSTOMER_NOT_RESPONDING') as CNR_count,
countif(ticket_history_sub_status = 'CUSTOMER_RESCHEDULE') as CUSTOMER_RESCHEDULE_count
 from
(
select
case_id,
status_timestamp,
ticket_history_status,
ticket_history_sub_status,
updatedby,
update_source,
allocated_entity,
consider_for_fake_flag,
--ekart_last_call_bridge_time,
engineer_name,
completed_timestamp,
--status_based_last_call_bridge_time,
techinician_id,
primary_issue,
secondary_issue,
status_bucket,
engineer_remark,
installation_type,
appointment_date,
allotted_date,
reason,
first_time_visit,
call_initiator_type,
cop_type,
cancelled_timestamp,
status_date,
ho_remarks,
lag(ticket_history_sub_status) over (PARTITION by case_id order by status_timestamp ) as previous_status,
lag(status_timestamp) over (PARTITION by case_id order by status_timestamp ) as previous_time,
case 
  when ticket_history_sub_status = lag(ticket_history_sub_status) over (PARTITION by case_id order by status_timestamp )
 and status_timestamp = lag(status_timestamp) over (PARTITION by case_id order by status_timestamp ) then 'Duplicate_entry'
 else 'Unique' end as unique_flag,
row_number() over (PARTITION by case_id order by status_timestamp ASC) rk_num
from bigfoot_external_neo.scp_jeeves__jeeves_ticket_history_fact
where case_id in (
'----------',
)
order by 
case_id,
status_timestamp,
ticket_history_sub_status
)x
group by all
order by case_id
),
ranked_data as 
(
select 
case_id,
ticket_history_sub_status,
ticket_history_status,
status_timestamp,
row_number() over (PARTITION by case_id, ticket_history_sub_status order by status_timestamp ASC) as status_rank,
from bigfoot_external_neo.scp_jeeves__jeeves_ticket_history_fact


