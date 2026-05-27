
WITH registration_data AS (
    SELECT 
  distinct
        vas_claim_id,
        policy_id,
		case 
		when UPPER(plan_name) Like '%TEST%' then 'Testing'
		when policy_type = 'VAS' and 
	(upper(construct_name) Like '%EXTENDED WARRANTY PLAN FOR AC%' or
		upper(construct_name) Like '%MAINTENANCE PLAN%' or
	upper(construct_name) Like '%FURNITURE MAINTENANCE%' or
	 upper(construct_name) Like '%COMPLETE REF & WM PROTECTION 3 YEAR%' or
	upper(construct_name) Like '%EXTENDED WARRANTY FOR LAPTOP%' or
	upper(construct_name) Like '%EXTENDED WARRANTY 2%' or
	upper(construct_name) Like '%EXTENDED WARRANTY 1%' or
	upper(construct_name) Like '%DAMAGE PROTECTION%' or
	 upper(construct_name) Like '%COMPLETE PROTECTION WASHING MACHINE%' or
	 upper(construct_name) Like '%FURNITURE MAINTAINENCE PLAN%' or
	upper(construct_name) Like '%DIAGNOSTIC%' or
	upper(construct_name) Like '%COMPLETE TV PROTECTION%' or
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
		claim_status,
        vas_status,
        vas_sub_status,
        DATE(vas_claim_registered_timestamp) AS claim_date,
        vas_claim_registered_timestamp,
        vas_last_update_on,
        plan_name,
        sales_channel,
        construct_name,
        brand_name,
        policy_type,
        kyi_repair_mode
    FROM bigfoot_external_neo.scp_jeeves__vas_claims_base_fact 
    WHERE DATE(vas_claim_registered_timestamp) >= '2025-01-01'
),
January_data AS (
    SELECT * 
    FROM registration_data
    WHERE claim_date BETWEEN '2025-01-01' AND '2025-01-31' and  New_Plan NOT IN ( 'Testing', 'Others')
),
Policy_claim_counts AS (
    SELECT 
        policy_id,
        COUNT(DISTINCT vas_claim_id) AS claim_count
    FROM registration_data
 
    GROUP BY policy_id
),
First_last_status AS (
    SELECT
        policy_id,
        FIRST_VALUE(claim_status) OVER (PARTITION BY policy_id ORDER BY vas_claim_registered_timestamp ASC) AS first_status,
         FIRST_VALUE(claim_status) OVER (PARTITION BY policy_id ORDER BY vas_claim_registered_timestamp DESC) AS last_status,
        FROM registration_data
)
SELECT 
    j.*,
    CASE 
        WHEN p.claim_count > 1 THEN 'Repeat'
        ELSE 'First Time'
    END AS claim_type,
    f.first_status,
       f.last_status,
   FROM January_data j
LEFT JOIN Policy_claim_counts p ON j.policy_id = p.policy_id
LEFT JOIN (
    SELECT DISTINCT policy_id, first_status, last_status
    FROM First_last_status
) f ON j.policy_id = f.policy_id



----------sevendays and sameday repeat---------------------

WITH registration_data AS (
    SELECT 
  distinct
        vas_claim_id,
        policy_id,
		case 
		when UPPER(plan_name) Like '%TEST%' then 'Testing'
		when policy_type = 'VAS' and 
	(upper(construct_name) Like '%EXTENDED WARRANTY PLAN FOR AC%' or
		upper(construct_name) Like '%MAINTENANCE PLAN%' or
	upper(construct_name) Like '%FURNITURE MAINTENANCE%' or
	 upper(construct_name) Like '%COMPLETE REF & WM PROTECTION 3 YEAR%' or
	upper(construct_name) Like '%EXTENDED WARRANTY FOR LAPTOP%' or
	upper(construct_name) Like '%EXTENDED WARRANTY 2%' or
	upper(construct_name) Like '%EXTENDED WARRANTY 1%' or
	upper(construct_name) Like '%DAMAGE PROTECTION%' or
	 upper(construct_name) Like '%COMPLETE PROTECTION WASHING MACHINE%' or
	 upper(construct_name) Like '%FURNITURE MAINTAINENCE PLAN%' or
	upper(construct_name) Like '%DIAGNOSTIC%' or
	upper(construct_name) Like '%COMPLETE TV PROTECTION%' or
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
		claim_status,
        vas_status,
        vas_sub_status,
        DATE(vas_claim_registered_timestamp) AS claim_date,
        vas_claim_registered_timestamp,
        vas_last_update_on,
        plan_name,
        sales_channel,
        construct_name,
        brand_name,
        policy_type,
        kyi_repair_mode
    FROM bigfoot_external_neo.scp_jeeves__vas_claims_base_fact 
    WHERE DATE(vas_claim_registered_timestamp) >= '2025-01-01'
),
January_data AS (
    SELECT * 
    FROM registration_data
    WHERE claim_date BETWEEN '2025-01-01' AND '2025-01-31' and  New_Plan NOT IN ( 'Testing', 'Others')
),
Policy_claim_counts AS (
    SELECT 
        policy_id,
        COUNT(DISTINCT vas_claim_id) AS claim_count
    FROM registration_data
     GROUP BY policy_id
),
First_last_status AS (
    SELECT
        policy_id,
        FIRST_VALUE(claim_status) OVER (PARTITION BY policy_id ORDER BY vas_claim_registered_timestamp ASC) AS first_status,
         FIRST_VALUE(claim_status) OVER (PARTITION BY policy_id ORDER BY vas_claim_registered_timestamp DESC) AS last_status,
        FROM registration_data
),
Lagged_Claims as
(
  select *,
  lag(vas_claim_registered_timestamp, 1) over (partition by policy_id order by vas_claim_registered_timestamp) as previous_claim_registration
  from January_data
)
SELECT 
    j.*,
    CASE 
        WHEN p.claim_count > 1 THEN 'Repeat'
        ELSE 'First Time'
    END AS overall_claim_type,
	case 
	when TIMESTAMP_DIFF(j.vas_claim_registered_timestamp, j.previous_claim_registration, day) =1
	and j.previous_claim_registration IS NOT NULL then TRUE else FALSE END AS day1_repeat, 
	case
	when TIMESTAMP_DIFF(j.vas_claim_registered_timestamp, j.previous_claim_registration, day) <=7
	and j.previous_claim_registration is NOT NULL then TRUE else FALSE END as day7_Repeat,
    f.first_status,
       f.last_status,
   FROM Lagged_Claims j
LEFT JOIN Policy_claim_counts p ON j.policy_id = p.policy_id
LEFT JOIN (
    SELECT DISTINCT policy_id, first_status, last_status
    FROM First_last_status
) f ON j.policy_id = f.policy_id

