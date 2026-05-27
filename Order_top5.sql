sElEcT * fRoM (WITH Cte AS (
    SELECT 
        DISTINCT f.thread_id,
        f.agent_id,
        f.incident_id,
        f.channel_name,
       to_date(f.thread_created_at) as date,
        f.queue_name,
        f.partner_location,
        f.sub_issue_name,
        a.status_type
    FROM bigfoot_external_neo.analytics_management__ims_thread_with_session_id_history_fact AS f
    LEFT JOIN bigfoot_external_neo.sp_seller_support__agent_incident_hive_fact AS a 
        ON f.agent_id = a.agent_id
    WHERE lookup_date(f.thread_created_at) BETWEEN '20240801' AND '20240805'
),
cte1 as(
SELECT 
      count( b.thread_id) as count_thread,
        b.agent_id,
        b.channel_name,
       b.date,
        dense_rank() over(order by  b.channel_name) as Dense_count
   FROM Cte as b
			   group by b.agent_id, b.channel_name,b.date
) ,
 Cte3 as (
select g.*, 
			   dense_rank() over(PARTITION by  g.Dense_count order by g.count_thread Desc) as number_dense
			   from cte1 as g
			   order by g.Dense_count desc
					  )  
select * from Cte3 as u
 where 
			 u.Dense_count <=5 and 
           u.number_dense <=5
order by u.Dense_count Desc)
			   qaas_injected_alias
			   
			   
			   ----------------------------------------------------------------------------------------------------------
			   
			   sElEcT * fRoM (WITH Cte AS (
    SELECT 
        DISTINCT f.thread_id,
        f.agent_id,
        f.incident_id,
        f.channel_name,
       to_date(f.thread_created_at) as date,
        f.queue_name,
        f.partner_location,
        f.sub_issue_name,
        a.status_type
    FROM bigfoot_external_neo.analytics_management__ims_thread_with_session_id_history_fact AS f
    LEFT JOIN bigfoot_external_neo.sp_seller_support__agent_incident_hive_fact AS a 
        ON f.agent_id = a.agent_id
    WHERE lookup_date(f.thread_created_at) BETWEEN '20240801' AND '20240805'
),
cte1 as(
SELECT 
      count( b.thread_id) as count_thread,
        b.agent_id,
        b.channel_name,
       b.date,
        dense_rank() over(order by  b.channel_name) as Dense_count
   FROM Cte as b
			   group by b.agent_id, b.channel_name,b.date
) ,
 Cte3 as (
select g.*, 
			   row_number() over(PARTITION by  g.Dense_count order by g.count_thread Desc) as number_dense
			   from cte1 as g
			   order by g.Dense_count desc
					  )  
select * from Cte3 as u
 where 
			 u.Dense_count <=5 and 
           u.number_dense <=5
order by u.Dense_count Desc)
			   qaas_injected_alias
			   
			   
			   
			   
			   
			   bigfoot_external_neo.retail_hermes__retail_products_fact
			   retail_products_fact---productid
			   
			   bigfoot_external_neo.cp_bi_prod_sales__forward_unit_fact
			   
			   
			   
			   
			   ----------------------
			   
			   
With Cte1 as(
select count("Case ID") as case_count,"Incident Type","Source","Status" from srms
where "Created On" >= Now() - interval '39 day'
group by"Incident Type","Source","Status"
	),
Cte2 as	
	(
	select b.*, 
		case when "Status" = 'RESOLVED' then 'Resolved'
		else 'Unresolved'
	end as Status_1,
		dense_rank() over (partition by b."Status" order by "case_count" Desc) as rank_status
	from Cte1 as b
	group by  b."Incident Type",b."Source", b."Status", b.case_count
	Order by b."Status"  Desc, b."Source" Asc ),
	Cte3 as (
	Select c.*,
		row_number() over (partition by c."status_1" order by "case_count" Desc) as rank_status_1,
	rank() over (partition by c.rank_status order by c.case_count Desc) as New_Rank
	from Cte2 as c
	order by   c.case_count desc)
	select d.case_count, d."Incident Type", d.status_1, d.rank_status_1 from  cte3 as d
	where rank_status_1 <=10
	order by status_1,case_count desc
	


			   