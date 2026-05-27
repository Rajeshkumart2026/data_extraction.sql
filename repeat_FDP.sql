sElEcT * fRoM (WITH master_data AS 
(
  SELECT 
    a.brand_name,
    a.claim_status,
    a.client_order_id,
    a.construct_name,
    a.device_list_price,
    a.device_selling_price,
    a.kyi_repair_mode,
    a.kyi_select_claim_reason,
    a.kyi_symptom_description,
    a.kyi_what_happened_to_the_device,
    a.policy_id,
    a.policy_end_date,
    a.plan_name,
    a.policy_start_date,
    a.sales_channel,
    a.vas_claim_id,
    a.vas_claim_registered_timestamp,
    a.vas_last_update_on,
    a.vas_sub_status,
    a.policy_type 
  FROM bigfoot_external_neo.scp_jeeves__vas_claims_base_fact AS a
),
repeat_data AS
(
  SELECT  
    b.vas_claim_id,
    b.policy_id,
    b.claim_status,
    b.vas_sub_status,
    DATE(b.vas_claim_registered_timestamp) AS claim_date,
     LAG(b.vas_claim_id) OVER (partition by b.policy_id ORDER BY DATE(b.vas_claim_registered_timestamp)) AS lag_claim_id,
  case when
  LAG(b.vas_claim_id) OVER (partition by b.policy_id ORDER BY DATE(b.vas_claim_registered_timestamp)) = b.vas_claim_id then 1
  else 0
  end as repeat_status
      FROM master_data AS b
  WHERE b.vas_claim_registered_timestamp >= '2025-02-01'
    ),
	day_repeat as
			   (
SELECT e.claim_date, count(*) as total_claims,
			   sum(e.repeat_status) as total_repeat,
			   round((sum(e.repeat_status)*100)/count(*), 2) as repeat_percentage
			   from repeat_data as e
			   group by e.claim_date
			   order by e.claim_date
),
 monthly_repeat as
			   (
select
count(*) total_claims,
  sum(g.repeat_status) as total_repeat,
 round( (sum(g.repeat_status)* 100.0 )/(count(*)),2) as monthly_repeat	  
	from repeat_data as g)
			   select * from monthly_repeat)
  qaas_injected_alias
  
  
  
  -------------------------------
  
  
  sElEcT * fRoM (WITH master_data AS 
(
  SELECT 
    a.brand_name,
    a.claim_status,
    a.client_order_id,
    a.construct_name,
    a.device_list_price,
    a.device_selling_price,
    a.kyi_repair_mode,
    a.kyi_select_claim_reason,
    a.kyi_symptom_description,
    a.kyi_what_happened_to_the_device,
    a.policy_id,
    a.policy_end_date,
    a.plan_name,
    a.policy_start_date,
    a.sales_channel,
    a.vas_claim_id,
    a.vas_claim_registered_timestamp,
    a.vas_last_update_on,
    a.vas_sub_status,
    a.policy_type,
  case when policy_type = 'B2B' and UPPER(brand_name) IN ( "FLIPKART SMARTBUY", "MARQ BY FLIPKART", "MOTOROLA", "NOKIA", "REALME TECHLIFE", "SANSUI", "THOMSON" , "MARQ" ,"CARER" ,"REALME TECH", "MASTERCHEF", "BEARDO", "BILLION", "THE MAN COMPANY", "WROGN", "HRX", "REALME")  and sales_channel IN("flipkart", "digital", "FLIPKARTPLOFFLINE", "GANGNAMRET")
  then "Private_label" 
			when policy_type = "VAS" and plan_name like "Maintenance_Plan%" or plan_name in
				("Extended_Warranty_WASHING MACHIN", "Extended_Warranty_TELEVISIONS", "Extended_Warranty_MICROWAVE OVEN", "Complete_Protection_TELEVISIONS", "Extended_Warranty_AC", "Complete_Protection_REFRIGERATORS", "Extended_Warranty_REFRIGERATORS", "Complete_Laptop_Protection_LAPTOPS") then "VAS_Plan" 
		when policy_type = "VAS" and plan_name in ("Complete_Mobile_Protection_PHONE", "Screen_Protection_Plan_PHONE", "Complete_Protection_TABLET") then "CMP"
			else "Others"
			end as Plan_new_name,
  policy_type
  FROM bigfoot_external_neo.scp_jeeves__vas_claims_base_fact AS a
),
repeat_data AS
(
  SELECT  
    b.vas_claim_id,
    b.policy_id,
    b.claim_status,
    b.vas_sub_status,
   b.Plan_new_name,
    DATE(b.vas_claim_registered_timestamp) AS claim_date,
     LAG(b.vas_claim_id) OVER (partition by b.policy_id ORDER BY DATE(b.vas_claim_registered_timestamp)) AS lag_claim_id,
  case when
  LAG(b.vas_claim_id) OVER (partition by b.policy_id, b.Plan_new_name ORDER BY DATE(b.vas_claim_registered_timestamp)) = b.vas_claim_id then 1
  else 0
  end as repeat_status
      FROM master_data AS b
  WHERE b.vas_claim_registered_timestamp >= '2025-02-01'
    ),
	day_repeat as
			   (
SELECT e.claim_date, 
				e.Plan_new_name, 
				 count(*) as total_claims,
			   sum(e.repeat_status) as total_repeat,
			   round((sum(e.repeat_status)*100)/count(*), 2) as repeat_percentage
			   from repeat_data as e
			   group by e.claim_date, e.Plan_new_name
			   order by e.claim_date, e.Plan_new_name
)
 			   select * from master_data)
  qaas_injected_alias
  
  
  
  
  
  --------------------concatenate:------------
  
  
  sElEcT * fRoM (WITH master_data AS 
(
  SELECT 
    a.brand_name,
    a.claim_status,
    a.client_order_id,
    a.construct_name,
    a.device_list_price,
    a.device_selling_price,
    a.kyi_repair_mode,
    a.kyi_select_claim_reason,
    a.kyi_symptom_description,
    a.kyi_what_happened_to_the_device,
    a.policy_id,
    a.policy_end_date,
    a.plan_name,
    a.policy_start_date,
    a.sales_channel,
    a.vas_claim_id,
    Date(a.vas_claim_registered_timestamp) as Date,
    a.vas_last_update_on,
    a.vas_sub_status,
    a.policy_type,
  case when policy_type = 'B2B' and UPPER(brand_name) IN ( "FLIPKART SMARTBUY", "MARQ BY FLIPKART", "MOTOROLA", "NOKIA", "REALME TECHLIFE", "SANSUI", "THOMSON" , "MARQ" ,"CARER" ,"REALME TECH", "MASTERCHEF", "BEARDO", "BILLION", "THE MAN COMPANY", "WROGN", "HRX", "REALME")  and sales_channel IN("flipkart", "digital", "FLIPKARTPLOFFLINE", "GANGNAMRET")
  then "Private_label" 
			when policy_type = "VAS" and plan_name like "Maintenance_Plan%" or plan_name in
				("Extended_Warranty_WASHING MACHIN", "Extended_Warranty_TELEVISIONS", "Extended_Warranty_MICROWAVE OVEN", "Complete_Protection_TELEVISIONS", "Extended_Warranty_AC", "Complete_Protection_REFRIGERATORS", "Extended_Warranty_REFRIGERATORS", "Complete_Laptop_Protection_LAPTOPS") then "VAS_Plan" 
		when policy_type = "VAS" and plan_name in ("Complete_Mobile_Protection_PHONE", "Screen_Protection_Plan_PHONE", "Complete_Protection_TABLET") then "CMP"
			else "Others"
			end as Plan_new_name,
  policy_type
  FROM bigfoot_external_neo.scp_jeeves__vas_claims_base_fact AS a
  
 )
	select 
			   f.vas_claim_id,
			  f.Plan_new_name,
			   f.Date,
			   row_number() over (partition by f.vas_claim_id order by f.vas_claim_id , f.Date ) as row_num,
			   concat (
				 coalesce(f.claim_status, "NA") , '-',
				coalesce(f.vas_sub_status,"NA") , '-',
				coalesce(f.kyi_repair_mode, "NA"), '-',
				coalesce(f.kyi_symptom_description, "NA")) as SSI	   
			    from master_data as f
			   where f.Date between "2025-01-01" and "2025-01-31"
			  			  )
  qaas_injected_alias
  
  
  
  -------------------------------------------
  
  
  with master_date as 
(
select 
  case_id,
  status_date,
  Date(updated_on_new),
  concat
  (
	coalesce("call_status","NA"), "-" ,
	coalesce("status", "NA"),  "-",
	coalesce ("sub_status", "NA")) as Status_New
		from bigfoot_external_neo.scp_jeeves__jeeves_call_activity_fact
	)
  select 
  count(*) as  claim_count,
  b.case_id,
  b.call_status
  b.status_date,
  b.Status_New
  from master_date as b where status_date between "2025-01-01" and "2025-01-10"
  group by b.case_id, b.status_date, b.Status_New
  order by 
  b.case_id
  
  
  
  
  --------------------------------------
  
  
  
  with Jan_sub_activity as 
(
  select
  case_id,
   sub_activity as Jan_activity from
  ( select case_id,
   sub_activity, 
   date(registered_date) as reg_date,
   row_number() over (partition by case_id order by Date(registered_date) Desc) as rm
    from  bigfoot_external_neo.scp_jeeves__jeeves_closures_and_sales_fact  
  where date(registered_date) between '2024-08-01' and  '2024-12-31'
  )
  where rm=1
  ),
  Feb_sub_activity as 
(
  select
  case_id,
  sub_activity as feb_activity 
  from
(  
  select 
  case_id, 
  sub_activity,
  Date(registered_date) as reg_date,
  row_number() over(partition by case_id order by  Date(registered_date) ASC ) as rn
     from  bigfoot_external_neo.scp_jeeves__jeeves_closures_and_sales_fact  
  where date(registered_date) between '2025-01-01' and  '2025-02-28'
  )
  where rn=1 
  )
 select  
 j.case_id,
 j.Jan_activity,
 k.feb_activity,
 case 
 when  j.Jan_activity != k.feb_activity then "Changed"
 ELSE
 "No changes"
 end as status_cjhanges
 from Jan_sub_activity as j
left join Feb_sub_activity as k
on j.case_id = k.case_id


--------------------------------------


sElEcT * fRoM (with Jan_sub_activity as 
(
  select
  count(*),
  case_id, 
  Extract (Month from registered_date) as month
    from  bigfoot_external_neo.scp_jeeves__jeeves_closures_and_sales_fact   as a
  where date(registered_date) between '2025-01-01' and  '2025-02-28'
  group by a.case_id, Extract (Month from registered_date)
  having count(distinct EXTRACT(month from (registered_date) )) = 2
			   )
  select * from Jan_sub_activity
  ) qaas_injected_alias