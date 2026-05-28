with base_data as
(
select
order_item_id,
analytic_category,
gmv,
(gmv - (abs(coalesce(bank_offer_adjustment,0)) + abs(coalesce(promotion_discount_adjustment,0))
	+ abs(coalesce(fee,0)) + abs(coalesce(sourcing_fee_adjustment,0)) + abs(coalesce(handling_fee_value,0))
)) as total_variable_costs

 FROM bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
    WHERE DATE(order_date_time) between '2026-01-01'
	where upper(status) NOT IN ('CANCELLED' , 'RETURNED' )
)
select
order_item_id,
analytic_category,
gmv,
(gmv, total_variable_costs) as contribution_margin,
round(safe_divide((gmv - total_variable_costs), gmv),2) as contribution_margin_pct,
round(safe_divide(gmv, total_variable_costs),2) as gmv_to_cost_ratio
from base_data
limit 100
	
