with seller_returns as
(
select 
seller_id,
count(*) as return_counts
 FROM bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
    WHERE DATE(order_date_time) >= '2026-01-01'
	and return_created_date_time is not null
	group by 1
	),
ranked_data as
(
select *,
sum(return_counts) over( order by return_counts DESC)/ sum(return_counts) over() as cummulative_returns_pct,
row_number() over (order by return_counts DESC) as seller_rank,
count(*) over () as total_seller_count
from seller_returns
)
select 
*,
safe_divide(seller_rank, total_seller_count ) as cummulative_seller_pct
from ranked_data
where cummulative_returns_pct <= 0.80
order by return_counts DESC 

	
