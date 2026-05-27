-----Happy Attach child and parent order details
select ef.*, 
s.Policy_status_flag,
s.Policy_Start,
s.Policy_End from 
(
select
distinct
child_id,
child_status,
child_order_id,
child_product_title,
child_type, 
parent_id,
parent_status,
parent_order_id,
parent_product_title,
parent_type,
child_order_date_key,
parent_order_date_key,
parent_analytic_vertical,
child_analytic_vertical,
order_date,
parent_IPD,
child_IPD,
delivered_date_child,
delivered_date_parent,
unit_is_rtod,
row_number() over (PARTITION by child_id order by order_date desc) as rnk_desc,
CASE when parent_status in ( 'DELIVERED',  'RETURN_REQUESTED') and unit_is_rtod= FALSE then 
( CASE WHEN
			DATE_DIFF(CURRENT_DATE(), DATE(delivered_date_parent), DAY) <= 30 THEN 'Active' 
        WHEN DATE_DIFF(CURRENT_DATE(), DATE(delivered_date_parent), DAY) > 30 THEN 'In-active' 
        ELSE 'Status_NA' end )
		else 'Non_delivered_status'
      END AS Policy_active_status
 
 from
(select
a.id as child_id,
 a.status as child_status,
 a.order_external_id as child_order_id,
 a.product_title as child_product_title,
  a.type as child_type,
 a.order_date_key as child_order_date_key,
  a.analytic_vertical as child_analytic_vertical,
 date(a.order_date_time) as order_date,
  date(a.initial_promise_date_time) as child_IPD,
 date(a.delivered_date_time) as delivered_date_child,
 unit_is_rtod as unit_is_rtod_child
   from
bigfoot_external_neo.cp_bi_prod_sales__forward_unit_history_fact as a 
where order_date_key>=20251101
and product_title LIKE 'Flipkart Trust Shield%'
 ) as a
 inner join
 (select
id as parent_id,
 status as parent_status,
 order_external_id as parent_order_id,
 product_title as parent_product_title,
  analytic_vertical as parent_analytic_vertical,
  type as parent_type,
  order_date_key as parent_order_date_key,
  date(initial_promise_date_time) as parent_IPD,
  date(delivered_date_time) as delivered_date_parent,
  unit_is_rtod 
  
from
bigfoot_external_neo.cp_bi_prod_sales__forward_unit_history_fact
where order_date_key>=20251101
and type  IN ('physical')
   and product_title NOT LIKE 'Flipkart Trust Shield%'
  and  analytic_vertical IN ('AirConditioner','Television','Refrigerator','WashingMachineDryer','MicrowaveOven','Handset')
  
   ) as b
      on a.child_order_id=b.parent_order_id )as ef 
	  left join (
	  select * from 
	  ( select s.vas_policy_id,
	  s.client_order_id,
	  s.construct_title,
	  s.policy_status,
	  s.policy_purchase_date, 
	  Date(s.policy_start_date) as Policy_Start,
	  Date(s.policy_end_date) as Policy_End,
   case when CURRENT_DATE  <= s.policy_end_date then 'Active' 
else 'Inactive'
end as Policy_status_flag ,
row_number() over (PARTITION by client_order_id order by policy_purchase_date desc, vas_policy_id DESC) as s_rank 
	  from bigfoot_external_neo.scp_jeeves__vas_sales_base_fact s ) 
	  where s_rank =1
	  )
	  as s
	  on ef.parent_order_id = s.client_order_id
	  where ef.rnk_desc = 1
	  
	  