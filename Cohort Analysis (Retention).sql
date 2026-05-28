with first_user as
(
select 
account_id,
min(order_date_time) as first_date

 FROM bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
    WHERE DATE(order_date_time) >= '2026-01-01'
	group by 1
	)
select
format_date('%y-%m', f.first_date ) as cohert_month,
count(DISTINCT f.account_id) as total_count,
count(distinct case when t.order_date_time > f.first_date then t.account_id  end) as retained_users,
round(safe_divide(count(DISTINCT case when t.order_date_time > f.first_date then t.account_id end), count(DISTINCT f.account_id)) * 100,2) as retention_pct
from first_user as f
left join  bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact as t
on t.account_id = f.account_id
group by 1
order by cohert_month ASC

	
