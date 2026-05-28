with base_data as(
select
customer_id,
date_diff(current_date(), max(order_date), DAY) as recency,
count(order_id) as frequency,
sum(gmv) as monetory
from order_sales
where order_date > = date_sub(current_date(), interval 1 year)
),
rfm_scores as
(
select 
customer_id,
ntile(5) over (order by recency DESC) as r_score,
ntile(5) over ( order by frequency ASC) as f_score,
ntile(5) over (order by monetory asc) as m_score
from base_data
)
select
customer_id,
r_score,
f_score,
m_score,
concat(r_score, f_score,m_score) as rfm_combined,
case when r_score >= 4, f_score >= 4 and m_score >=4 then 'champion'
        when r_score > 4 and f_score <=2 then 'New_Customers'
        when r_score <=2 and f_score >=4 then 'Risk'
        when r_score <=4 and f_score <=4 then 'Hibernating
        else 'Regulars'
        end as customer_segment
        from rfm_scores
