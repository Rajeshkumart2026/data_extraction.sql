with inventory_data as 
(
select
product_id,
stock_date,
stock_quantity,
lag(stock_quantity, 30) over (partition by product_id order by stock_date ) as previous_stock
from inventory 
)
select *,
from inventory_data
where stock_date = current_date()
and stock_quantity < previous_stock
