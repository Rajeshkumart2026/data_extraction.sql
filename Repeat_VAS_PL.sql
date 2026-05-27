WITH registration_data AS (
    SELECT 
  distinct
        vas_claim_id,
        policy_id,
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
	upper(construct_name) Like '%ASUS COMMERCIAL SERVICE PACK%' or
	 upper(construct_name) Like '%ASUS COMMERCIAL LAPTOP%' or
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
   upper(plan_name) Like '%EXTENDED_WARRANTY_PHONE%' or
   upper(construct_name) Like '%SCREEN PROTECTION PLAN%' or
	upper(construct_name) Like '%MOBILE%' or
	upper(construct_name) Like '%TABLET%'
  ) then 'CMP'
   when policy_type = 'B2B' and
   (upper(plan_name) Like  '%BRAND_WARRANTY%' or 
   upper(construct_name) Like '%BRAND_WARRANTY%' or
   upper(construct_name) Like '%BRAND WARRANTY%' or
   upper(construct_name) Like '%BW %' or
   upper(construct_name) Like '%BAND WARRANTY%' or
   upper(construct_name) Like '%PL_%' or
   upper(construct_name) Like '%_PL%' or
      upper(construct_name) Like '%PL AIR_COOLER_%' or
   upper(construct_name) Like '%Pl_REFRIGERATOR_CONSTRUCT%' or
   upper(construct_name) Like '%PLB2B_WATERGEYSER%' or
   
   upper(construct_name) Like '%GANGNAM%' or
   upper(construct_name) Like '%WALKIN_PRIVATE LABEL_KITCHEN APPLIANCES%' or
   upper(construct_name) Like '%PB_TELEVISION%' or
   upper(construct_name) Like '%_PL%') then 'PL'
     
	else 'Others'
  END as New_Plan,
		claim_status,
        vas_status,
        vas_sub_status,
        DATE(vas_claim_registered_timestamp) AS claim_date,
        vas_claim_registered_timestamp,
        vas_last_update_on,
        plan_name,
        construct_name,
        brand_name,
        policy_type,
        kyi_repair_mode
    FROM bigfoot_external_neo.scp_jeeves__vas_claims_base_fact 
    WHERE DATE(vas_claim_registered_timestamp) >=  DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY) 
),
Policy_claim_counts AS (
    SELECT 
        policy_id,
        COUNT(DISTINCT vas_claim_id) AS claim_count
    FROM registration_data
    GROUP BY policy_id
),
 last2_status AS (
    SELECT * from 
  ( select 
        policy_id,
        claim_status as Previous_status,
   row_number() over (partition by policy_id order by vas_claim_registered_timestamp Desc ) as policy_rank
        FROM registration_data where New_Plan NOT IN ( 'Others')
) X
  where policy_rank =2
  )
SELECT 
    j.*,
    CASE 
        WHEN p.claim_count > 1 THEN 'Repeat'
        ELSE 'First Time'
    END AS claim_type,
   	p.claim_count,
	f.Previous_status
   FROM registration_data j
LEFT JOIN Policy_claim_counts p ON j.policy_id = p.policy_id
LEFT JOIN last2_status f ON j.policy_id = f.policy_id
where  j.New_Plan NOT IN ( 'Others') 