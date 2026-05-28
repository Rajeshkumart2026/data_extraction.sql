with ProductFrequencies AS
(
SELECT
product_id,
count(*) as total_counts
from order_items 
group by 1
),
ProductPairs as
(
SELECT
a.product_id as p1,
b.product_id as p2,
count(*) as pair_count

from order_items a 
join order_items b 
on a.order_id = b.order_id
where a.product_id < b.product_id
group by 1,2
)
select 
pp.p1,
pp.p2,
pp.pair_count,
pp.pair_count * 1.0 / (pp1.total_counts + pp2.total_counts - pp.pair_count) as similarity_score


from ProductPairs pp
join ProductFrequencies pf1 
on pp.p1 = pf1.product_id
join ProductFrequencies pf2 
on pp.p2 = pf2.product_id
