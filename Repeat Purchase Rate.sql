with user_metrics as
(
select
account_id,
case 
	when safe_divide(abs(coalesce(bank_offer_adjustment,0)) + abs(coalesce(promotion_discount_adjustment,0)), gmv) >0.15 then 'High Discount Seeker'
		when (coalesce(bank_offer_adjustment,0) = 0 and coalesce(promotion_discount_adjustment,0)=0) then 'Full Price Buyer'
		else 'Moderate'
		end as customer_segment,
sum(gmv -(
      ABS(COALESCE(bank_offer_adjustment, 0)) + 
      ABS(COALESCE(promotion_discount_adjustment, 0)) + 
      ABS(COALESCE(shipping_discount_value, 0)) + 
      ABS(COALESCE(fee, 0)) + 
      ABS(COALESCE(sourcing_fee_adjustment, 0)) 
    )) AS user_total_net_contribution,
count(DISTINCT order_item_id) as total_orders_per_user,		
FROM bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
    WHERE DATE(order_date_time) >= '2026-01-01'
and upper(status) NOT IN ('CANCELLED', 'RETURED')
group by 1,2
)

select
customer_segment,
count(DISTINCT account_id) as total_customers,
round(safe_divide(count(case when total_orders_per_user > 1 then 1 end), count(account_id)) * 100, 2) as repeat_purchase_rate,
round(safe_divide(count(case when user_total_net_contribution < 0  then 1 end), count(account_id))* 100,2) as unprofitable_user_pct,
round(avg(user_total_net_contribution),2) as avg_lifetime_value_contribution
from user_metrics
group by 1
order by avg_lifetime_value_contribution desc
