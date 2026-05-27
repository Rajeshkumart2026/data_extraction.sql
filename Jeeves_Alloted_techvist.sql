With ranked_data as 
(
select 
a.case_id,
b.vas_claim_id,
 b.policy_id,
 b.vas_status,
 DATE(b.vas_claim_registered_timestamp) as claim_registerd_date,
 b.plan_name,
 b.construct_name,
 b.brand_name,
 b.client,
 b.policy_type,
a.ticket_history_sub_status,
a.ticket_history_status,
a.status_timestamp,
case 
		when policy_type = 'VAS' and 
	(upper(construct_name) Like '%EXTENDED WARRANTY PLAN FOR AC%' or
		upper(construct_name) Like '%MAINTENANCE PLAN%' or
	upper(construct_name) Like '%FURNITURE MAINTENANCE%' or
	 upper(construct_name) Like '%COMPLETE REF & WM PROTECTION 3 YEAR%' or
	upper(construct_name) Like '%EXTENDED WARRANTY FOR LAPTOP%' or
	upper(construct_name) Like '%EXTENDED WARRANTY 2%' or
	upper(construct_name) Like '%EXTENDED WARRANTY%' or
	upper(construct_name) Like '%EXTENDED WARRANTY 1%' or
	upper(construct_name) Like '%DAMAGE PROTECTION%' or
	 upper(construct_name) Like '%COMPLETE PROTECTION WASHING MACHINE%' or
	 upper(construct_name) Like '%FURNITURE MAINTAINENCE PLAN%' or
	upper(construct_name) Like '%DIAGNOSTIC%' or
	upper(construct_name) Like '%COMPLETE TV PROTECTION%' or
	upper(construct_title) Like '%ASUS COMMERCIAL SERVICE PACK%' or
	 upper(construct_title) Like '%ASUS COMMERCIAL LAPTOP%' or
	upper(construct_name) Like '%COMPLETE PROTECTION REFRIGERATOR %' or
	upper(construct_name) Like '%COMPLETE LAPTOP PROTECTION %' or
	upper(construct_name) Like '%COMPLETE APPLIANCES PROTECTION%' or
	upper(construct_name) Like '%CLEANING SERVICE%' or
	upper(construct_name) Like '%MAINTENANCE PLAN%' or
	 upper(plan_name) Like '%EXTENDED_WARRANTY_MICROWAVE OVEN%' or
	upper(plan_name) Like '%COMPLETE_PROTECTION_REFRIGERATORS%' or
	upper(plan_name) Like '%COMPLETE_PROTECTION_WASHING MACHINES%' or
	upper(plan_name) Like '%COMPLETE_PROTECTION_TELEVISIONS%' or
	 upper(plan_name) Like '%EXTENDED_WARRANTY_TELEVISIONS%' or
	upper(plan_name) Like '%EXTENDED_WARRANTY_REFRIGERATORS%'  ) then 'VAS'
		 when policy_type = 'VAS'  and 
  (upper(construct_name) Like '%COMPLETE MOBILE PROTECTION%' or
   upper(construct_name) Like '%SCREEN PROTECTION PLAN%' or
	upper(construct_name) Like '%MOBILE%' or
	upper(construct_name) Like '%TABLET%'
  ) then 'CMP'
	when policy_type = 'B2B' and
	((upper(brand_name) IN ('FLIPKART SMARTBUY','MARQ BY FLIPKART','MOTOROLA','NOKIA',
	'REALME TECHLIFE','MARQ','CARER','REALME TECH',
'MASTERCHEF','BEARDO','BILLION','THE MAN COMPANY','WROGN','HRX','REALME','KENSTAR') and 
upper(sales_channel) IN ('FLIPKART', 'DIGITAL', 'FLIPKARTPLOFFLINE','GANGNAMRET')) 
or (upper(brand_name) IN ('SANSUI','THOMSON') 
	and upper(sales_channel) IN ('FLIPKART', 'DIGITAL', 'FLIPKARTPLOFFLINE', 'GANGNAMRET') 
	and kyi_repair_mode = 'Walk-in' ))
 then 'PL'
  else 'Others'
  END as New_Plan,
row_number() over (PARTITION by case_id, ticket_history_sub_status order by status_timestamp ASC) as status_rank,
from bigfoot_external_neo.scp_jeeves__jeeves_ticket_history_fact as a
  left join bigfoot_external_neo.scp_jeeves__vas_claims_base_fact as b
  on a.case_id = b.service_partner_request_id
  where date(status_timestamp) >='2025-07-01'

/*where 
case_id in (
'FLIS-3QESMV-H9HDRE-8GETDO-SFFNYL4',
'FLIS-5J2DW8-KYCQHJ-EPFEIL-XTU1I8Z',
'FLIS-5LQX32-GL3QDN-1PFJN3-KJDK4CV',
'FLIR-18R85D-458IKT-0XVM8H-3C5JR7',
'FLIG-9CDXSZ-O0HA5S-4SONQD-TKNDRCG',
'FLIX-7R3EAH-S8A0FO-U24IEJ-11PJEJV',
'FLIR-8CZWZG-2TP904-FES6HY-XS01I9I')*/
),
pivoted as
(
select 
case_id,
claim_registerd_date,
New_Plan,
vas_claim_id,
policy_id,
vas_status,
construct_name,
MAX(if(upper(ticket_history_sub_status) = 'CREATED' and status_rank = 1, status_timestamp,null)) as created_1_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'ALLOCATED' and status_rank = 1 , status_timestamp, null)) as alloted_1_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'RESCHEDULED' and status_rank = 1 , status_timestamp, null)) as rescheduled_1_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'TECHNICIAN_REACHED_SITE' and status_rank = 1 , status_timestamp, null)) as TECHNICIAN_REACHED_SITE_1_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_NOT_RESPONDING' and status_rank = 1 , status_timestamp, null) )as CUSTOMER_NOT_RESPONDING_1_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_RESCHEDULE' and status_rank = 1 , status_timestamp, null)) as CUSTOMER_RESCHEDULE_1_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'COMPLETED' and status_rank = 1 , status_timestamp, null)) as COMPLETED,
MAX(if(upper(ticket_history_sub_status) = 'REOPENED' and status_rank = 1 , status_timestamp, null)) as REOPENED,
MAX(if(upper(ticket_history_sub_status) = 'CREATED' and status_rank = 2, status_timestamp,null)) as created_2_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'ALLOCATED' and status_rank = 2 , status_timestamp, null)) as alloted_2_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'RESCHEDULED' and status_rank = 2 , status_timestamp, null)) as rescheduled_2_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'TECHNICIAN_REACHED_SITE' and status_rank = 2 , status_timestamp, null)) as TECHNICIAN_REACHED_SITE_2_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_NOT_RESPONDING' and status_rank = 2 , status_timestamp, null) )as CUSTOMER_NOT_RESPONDING_2_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_RESCHEDULE' and status_rank = 2 , status_timestamp, null)) as CUSTOMER_RESCHEDULE_2_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CREATED' and status_rank = 3, status_timestamp,null)) as created_3_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'ALLOCATED' and status_rank = 3 , status_timestamp, null)) as alloted_3_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'RESCHEDULED' and status_rank = 3 , status_timestamp, null)) as rescheduled_3_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'TECHNICIAN_REACHED_SITE' and status_rank = 3 , status_timestamp, null)) as TECHNICIAN_REACHED_SITE_3_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_NOT_RESPONDING' and status_rank = 3 , status_timestamp, null)) as CUSTOMER_NOT_RESPONDING_3_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_RESCHEDULE' and status_rank = 3 , status_timestamp, null)) as CUSTOMER_RESCHEDULE_3_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CREATED' and status_rank = 4, status_timestamp,null)) as created_4_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'ALLOCATED' and status_rank = 4 , status_timestamp, null)) as alloted_4_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'RESCHEDULED' and status_rank = 4 , status_timestamp, null)) as rescheduled_4_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'TECHNICIAN_REACHED_SITE' and status_rank = 4 , status_timestamp, null)) as TECHNICIAN_REACHED_SITE_4_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_NOT_RESPONDING' and status_rank = 4 , status_timestamp, null)) as CUSTOMER_NOT_RESPONDING_4_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_RESCHEDULE' and status_rank = 4 , status_timestamp, null)) as CUSTOMER_RESCHEDULE_4_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CREATED' and status_rank = 5, status_timestamp,null)) as created_5_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'ALLOCATED' and status_rank = 5 , status_timestamp, null)) as alloted_5_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'RESCHEDULED' and status_rank = 5 , status_timestamp, null)) as rescheduled_5_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'TECHNICIAN_REACHED_SITE' and status_rank = 5 , status_timestamp, null)) as TECHNICIAN_REACHED_SITE_5_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_NOT_RESPONDING' and status_rank = 5 , status_timestamp, null)) as CUSTOMER_NOT_RESPONDING_5_status_timestamp,
MAX(if(upper(ticket_history_sub_status) = 'CUSTOMER_RESCHEDULE' and status_rank = 5 , status_timestamp, null)) as CUSTOMER_RESCHEDULE_5_status_timestamp
from ranked_data
group by case_id, claim_registerd_date),
Summary_view as
(
SELECT
  case_id,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'CREATED' THEN 1 ELSE 0 END) AS created_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'ALLOCATED' THEN 1 ELSE 0 END) AS alloted_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'RESCHEDULED' THEN 1 ELSE 0 END) AS rescheduled_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'TECHNICIAN_REACHED_SITE' THEN 1 ELSE 0 END) AS tech_visit_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'CUSTOMER_RESCHEDULE' THEN 1 ELSE 0 END) AS customer_resc_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'CUSTOMER_NOT_RESPONDING' THEN 1 ELSE 0 END) AS cnr_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'CLOSED' THEN 1 ELSE 0 END) AS closed_count,
  SUM(CASE WHEN upper(ticket_history_sub_status) = 'REOPENED' THEN 1 ELSE 0 END) AS reopen_count
FROM ranked_data
GROUP BY case_id
),
Days_difference as
(
select
case_id,
vas_claim_id,
policy_id,
claim_registerd_date,
alloted_1_status_timestamp,
New_Plan,
TIMESTAMP_DIFF(alloted_1_status_timestamp, claim_registerd_date, DAY) AS registered_to_alloted_1days

/*TIMESTAMP_diff(rescheduled_1_status_timestamp,created_1_status_timestamp, DAY) as first_rescheduled,
TIMESTAMP_diff(alloted_1_status_timestamp,created_1_status_timestamp, DAY) as first_alloted,
TIMESTAMP_diff(TECHNICIAN_REACHED_SITE_1_status_timestamp, created_1_status_timestamp, DAY) as first_tech_reschudule,
TIMESTAMP_diff(CUSTOMER_NOT_RESPONDING_1_status_timestamp, created_1_status_timestamp, DAY) as FIRST_CNR,
TIMESTAMP_diff(CUSTOMER_RESCHEDULE_1_status_timestamp, created_1_status_timestamp, DAY) AS FIRST_CUS_RESCHEDULE,
TIMESTAMP_diff(rescheduled_2_status_timestamp,created_1_status_timestamp, DAY) as second_rescheduled,
TIMESTAMP_diff(alloted_2_status_timestamp,created_1_status_timestamp, DAY) as second_alloted,
TIMESTAMP_diff(TECHNICIAN_REACHED_SITE_2_status_timestamp, created_1_status_timestamp, DAY) as second_tech_reschudule,
TIMESTAMP_diff(CUSTOMER_NOT_RESPONDING_2_status_timestamp, created_1_status_timestamp, DAY) as second_CNR,
TIMESTAMP_diff(CUSTOMER_RESCHEDULE_2_status_timestamp, created_1_status_timestamp, DAY) AS second_CUS_RESCHEDULE,
TIMESTAMP_diff(rescheduled_3_status_timestamp,created_1_status_timestamp, DAY) as three_rescheduled,
TIMESTAMP_diff(alloted_3_status_timestamp,created_1_status_timestamp, DAY) as three_alloted,
TIMESTAMP_diff(TECHNICIAN_REACHED_SITE_3_status_timestamp, created_1_status_timestamp, DAY) as three_tech_reschudule,
TIMESTAMP_diff(CUSTOMER_NOT_RESPONDING_3_status_timestamp, created_1_status_timestamp, DAY) as three_CNR,
TIMESTAMP_diff(CUSTOMER_RESCHEDULE_3_status_timestamp, created_1_status_timestamp, DAY) AS three_CUS_RESCHEDULE,
TIMESTAMP_DIFF(alloted_1_status_timestamp, claim_registerd_date, DAY) AS registered_to_alloted_1days,
TIMESTAMP_DIFF(alloted_2_status_timestamp, claim_registerd_date, DAY) AS registered_to_alloted_2days,
TIMESTAMP_DIFF(alloted_3_status_timestamp, claim_registerd_date, DAY) AS registered_to_alloted_3days,
TIMESTAMP_DIFF(alloted_4_status_timestamp, claim_registerd_date, DAY) AS registered_to_alloted_4days,
TIMESTAMP_DIFF(alloted_5_status_timestamp, claim_registerd_date, DAY) AS registered_to_alloted_5days */
FROM pivoted
)

select * from Summary_view