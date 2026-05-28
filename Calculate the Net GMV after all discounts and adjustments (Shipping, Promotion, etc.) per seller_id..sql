select
seller_id,
sum(GMV) as gross_gmv,
sum(gmv - promotion_discount_adjustment- shipping_charge_adjustment
        - exchange_discount_adjustment - freebie_discount_adjustment ) as net_gmv

from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_date_time) >= '2026-01-01'
and status not in ('CANCELLED', 'RETURNED')
group by seller_id
order by net_gmv DESC
