---------Happy_Attach_Reg_refund


select 
distinct(a.vas_claim_id),
a.policy_id,
a.claim_status,
a.vas_status,
a.vas_sub_status,
DATE(a.vas_claim_registered_timestamp) as claim_registerd_date,
a.vas_last_update_on,
a.vas_sr_event_last_updated_on,
a.vas_cancelled_date,
a.vas_final_outcome,
a.client_order_id,
a.repair_completion_date,
a.is_ber,
a.payment_date,
a.payment_initiated_date,
a.plan_name,
a.policy_purchase_date,
a.policy_start_date,
a.replacement_initiated_date,
a.replacement_completed_date,
a.replacement_status,
a.rmt_completion_timestamp,
a.rmt_outcome,
a.rmt_updated_by,
a.sales_channel,
a.claim_registered_by,
a.construct_name,
a.brand_name,
a.service_partner_request_id,
a.kyi_select_claim_reason,
a.kyi_what_happened_to_the_device,
a.kyi_what_issue_are_you_facing_with_device,
a.service_partner_name,
a.policy_type,
a.client,
a.kyi_repair_mode,
case when
  (upper(a.construct_name) Like 'FLIPKART TRUST SHIELD_TELEVISIONS%' or
   upper(a.construct_name) Like 'FLIPKART TRUST SHIELD_WASHING MACHINES%' or
	upper(a.construct_name) Like 'FLIPKART TRUST SHIELD_REFRIGERATOR%' or
	upper(a.construct_name) Like 'FLIPKART TRUST SHIELD_MICROWAVE OVEN%' or
	upper(a.construct_name) Like 'FLIPKART TRUST SHIELD_AC%' or 
	upper(a.construct_name) Like 'FLIPKART TRUST SHIELD_LAPTOP%' or
	upper(a.construct_name) Like 'FLIPKART TRUST SHIELD_MOBILE%'
  ) then 'Happy_Attach'
  else 'Others'
  END as New_Plan,
x.resolved_return_item_status,
x.return_item_reason,
x.return_reason,
o.analytic_vertical, 
o.analytic_business_unit,
o.id,
s.is_bsd,
s.service_provider,
pur.analytic_vertical as analytics_ver
FROM bigfoot_external_neo.scp_jeeves__vas_claims_base_fact as a

left join  (
select y.*,
  case when y.return_item_status IS NULL then 'No_Return' 
 else y.return_item_status end as
 resolved_return_item_status
 from
(
select
return_item_status,
return_item_reason,
forward_unit_id,
order_external_id,
return_item_request_date_time,  
return_reason,
return_sub_reason,
(case when return_action in ('wait_refund','refund_dnt_expect','refund_expect','customer_wants_refund','wait_dnt_refund') then 'Refund'
when return_action in ('wait_replace','replace_expect','replace_dnt_expect') then 'Replace'
when return_action in ('exchange_expect','wait_exchange','exchange_dnt_expect') then 'Exchange'
else '-'
end) rvp_return_action,
return_action,
row_number() over (partition by forward_unit_id order by return_item_request_date_time desc) as rn,
from bigfoot_external_neo.scp_rrr__return_l2_id_level_hive_ss_fact
where return_type='customer_return')y
where y.rn = 1 )x
on a.client_order_id =  x.order_external_id

left join (select id, order_external_id, analytic_vertical, analytic_business_unit, analytic_sub_category  
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_history_fact 
where
	order_date_key >= 20250601  and  type = 'physical'
	and product_title NOT LIKE 'Flipkart Trust Shield%') o 
	 on o.order_external_id = a.client_order_id 
left join (select p.vas_policy_id, p.client_order_id, p.analytic_business_unit, p.analytic_category, p.analytic_vertical  
from bigfoot_external_neo.scp_jeeves__vas_sales_base_fact as p ) pur
	 on a.policy_id = pur.vas_policy_id 
	 
left join (select is_bsd, client_brand_id,service_provider from bigfoot_external_neo.scp_jeeves__jeeves_closures_and_sales_fact ) as s
 on s.client_brand_id = a.client_order_id
WHERE DATE(a.vas_claim_registered_timestamp) >= '2025-07-01' and ( 
case when
  (upper(construct_name) Like 'FLIPKART TRUST SHIELD_TELEVISIONS%' or
   upper(construct_name) Like 'FLIPKART TRUST SHIELD_WASHING MACHINES%' or
	upper(construct_name) Like 'FLIPKART TRUST SHIELD_REFRIGERATOR%' or
	upper(construct_name) Like 'FLIPKART TRUST SHIELD_MICROWAVE OVEN%' or
	upper(construct_name) Like 'FLIPKART TRUST SHIELD_AC%' or 
	upper(construct_name) Like 'FLIPKART TRUST SHIELD_LAPTOP%' or
	upper(construct_name) Like 'FLIPKART TRUST SHIELD_MOBILE%'
  ) then 'Happy_Attach'
  else 'Others'
  END = 'Happy_Attach'
  )


