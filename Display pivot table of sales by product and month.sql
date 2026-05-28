select
product_id,
sum(case when month(order_date) = 1 then gmv else 0 end) as Jan,
sum(case when month(order_date) = 2 then gmv else 0 end) as Feb,
sum(case when month(order_date) = 3 then gmv else 0 end) as march
from order_detail od 
join orders as o 
on od.order_id = o.order_id
group by product_id
