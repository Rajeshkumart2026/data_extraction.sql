with vertical_metrics as
(
select
analytic_vertical,
round(avg(listing_quality_score),2) as strength_score,
round(count( case when return_created_date_time is not null then 1 end)* 100 /nullif(count(*),0),2) as weakness_return_rate,
round(count( case when promise_breach = 'Breach' then 1 end) * 100 / nullif(count(*),0),2) as threat_breach_rate,
sum(gmv) as opportunity_gmv_2026,
count(DISTINCT product_id) as selection_count
from bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
where date(order_created_at) >= '2025-01-01'
group by 1
)
select
*,
case when strength_score > 4.2 and weakness_return_rate < 5 then 'STRENGTH: Scalable Star'
	when weakness_return_rate > 15 then 'Weekness'
	when threat_breach_rate > 10 then 'threat'
	when strength_score > 4.0 and opportunity_gmv_2026 < 1000000 then 'OPPORTUNITY'
	else 'Neutral'
	end as strategic_priority
	for vertical_metrics
	order by opportunity_gmv_2026

