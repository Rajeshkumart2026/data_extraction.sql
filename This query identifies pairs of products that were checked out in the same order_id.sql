with successive_fact as
(
select
order_id,
product_id,
from products 
where status not in ('Returned', 'Cancelled')
and product_id is not null
),
frequency_purchased as
(
select
a.product_id as product_a,
b.product_id as product_b
from successive_fact as a 
join successive_fact as b 
on a.order_id = b.order_id
and a.product_id < b.product_id
)
select
product_a,
product_b,
count(*) as total_count
from frequency_purchased
group by 1,2
order by total_count desc



