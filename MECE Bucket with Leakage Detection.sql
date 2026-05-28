with mece_tree as
(
select
order_item_id,
analytic_category,
gmv,
(abs(coalesce(promotion_discount_adjustment,0)) + abs(coalesce(freebie_discount_adjustment,0)) + abs(coalesce(bundle_discount_adjustment,0))) as marketing_bucket,
abs(coalesce(bank_offer_adjustment,0)) as strategic_bank_bucket,

(abs(coalesce(shipping_discount_value,0)) + abs(coalesce(sourcing_fee_adjustment,0)) + 
abs(coalesce(handling_fee_value,0)) + abs(coalesce(fee,0))) as logistics_bucket,

abs(coalesce(exchange_discount_adjustment,0)) as lifecycle_bucket,

order_billing_amount as actual_final_billing
FROM bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
    WHERE DATE(order_date_time) >= '2026-01-01'
and upper(status) NOT IN ('CANCELLED', 'RETURED')
)

select
analytic_category,
sum(gmv) as total_gmv,
sum(marketing_bucket) as marketing_spend,
sum(strategic_bank_bucket) as bank_spend,
sum(logistics_bucket) as logistic_cost,
sum(lifecycle_bucket) as exchange_cost,
sum(gmv -(marketing_bucket +strategic_bank_bucket +logistics_bucket+lifecycle_bucket)) as unexplained_leakage
from mece_tree
group by 1
order by unexplained_leakage	

