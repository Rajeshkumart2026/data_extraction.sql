---------Happy_Attach_Reg_refund


select 
distinct(vas_claim_id),
policy_id,
claim_status,
vas_status,
vas_sub_status,
DATE(vas_claim_registered_timestamp) as claim_registerd_date,
vas_last_update_on,
vas_sr_event_last_updated_on,
vas_cancelled_date,
vas_final_outcome,
client_order_id,
repair_completion_date,
is_ber,
payment_date,
payment_initiated_date,
plan_name,
policy_purchase_date,
policy_start_date,
replacement_initiated_date,
replacement_completed_date,
replacement_status,
rmt_completion_timestamp,
rmt_outcome,
rmt_updated_by,
sales_channel,
claim_registered_by,
construct_name,
brand_name,
service_partner_request_id,
kyi_select_claim_reason,
kyi_what_happened_to_the_device,
kyi_what_issue_are_you_facing_with_device,
service_partner_name,
policy_type,
client,
kyi_repair_mode,
x.resolved_return_item_status,
x.return_item_reason,
x.return_reason,
o.analytic_vertical, 
o.analytic_business_unit,
s.is_bsd,
s.service_provider 
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

left join (select order_external_id, analytic_vertical, analytic_business_unit, analytic_sub_category  
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_history_fact 
where
	order_date_key >= 20250101  and  type = 'physical') o 
	 on o.order_external_id = a.client_order_id 
left join (select is_bsd, client_brand_id,service_provider from bigfoot_external_neo.scp_jeeves__jeeves_closures_and_sales_fact ) as s
 on s.client_brand_id = a.client_order_id



