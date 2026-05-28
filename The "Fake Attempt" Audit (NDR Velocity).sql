select
shipment_carrier,
count(*) as total_undeliverd_attempts,
count( case when extract(HOUR from first_undelivery_status_datetime) >= 20 or
		extract(HOUR from first_undelivery_status_datetime) <=6 then 1 end) as late_night_attempts,
		
round(count(case when extract( HOUR from first_undelivery_status_datetime) >=20
	and timestamp_diff(shipment_delivered_at_datetime, first_undelivery_status_datetime, HOUR)< 12
	then 1 end) * 100 / nullif(count(*),0),1) as fraud_probability_pct,
	
avg(timestamp_diff(shipment_delivered_at_datetime, first_undelivery_status_datetime, HOUR)) as avg_hrs_to_fix
from bigfoot_external_neo.scp_fulfillment__sc_large_breach_90_fact
where first_undelivery_status_datetime is not null and
	shipment_delivered_at_datetime is not null
	and date(order_item_created_at) >= '2026-01-01'
	group by 1
	order by fraud_probability_pct DESC
