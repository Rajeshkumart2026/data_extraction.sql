sElEcT * fRoM (with EHC_base as
(SELECT
        e.ehc_conversation_id,
        e.ping_conversation_id,
        e.order_unit_status,
		e.order_id,
		sales.marketplace_id,
		MIN(e.ts) as min_date,
		regexp_extract(order_unit_status, ':"([^"]+)"', 1) AS refined_status
		       FROM
        bigfoot_external_neo.mp_cs__effective_help_center_raw_fact as e
		left join  Bigfoot_external_neo.cp_bi_prod_sales__forward_unit_history_fact as sales
		on sales.order_external_id=e.order_id
		LEFT JOIN
      fdp_uploads.ds_fkint_bigfoot_demo_ehc_option_intent_mapping_1_0 o
      ON e.option_matched = o.optionid
				
      WHERE
	  order_date_key>=20251201
	  and date(e.ts)>= '2026-01-10'
		and  event_type IN ('EHC_MESSAGE_RECIEVED')
        AND ehc_conversation_id IS NOT NULL
		and ping_conversation_id IS NOT NULL
		and sales.marketplace_id = 'HYPERLOCAL'
		group by 
		 ehc_conversation_id,
        ping_conversation_id,
        order_unit_status,
		e.order_id,
		sales.marketplace_id,
		refined_status
		
		),
		ranking_data as 
		(
		select 	  
		ehc_conversation_id,
        ping_conversation_id,
        order_unit_status,
		order_id,
		marketplace_id,
		Date(min_date) as original_date,
		refined_status,
		dense_rank() OVER (PARTITION BY order_id ORDER BY ehc_conversation_id ASC) AS rn,
        Date(LAG(min_date) OVER (PARTITION BY order_id ORDER BY ehc_conversation_id ASC)) AS prev_conversation_date,
		LAG(order_id) OVER (PARTITION BY ping_conversation_id ORDER BY min_date ASC) AS prev_order_id
    FROM 
        EHC_base )
		select *,
		case when rn = 1 then 'new_conversation'
			 when ((z.original_date = z.prev_conversation_date) and (order_id = prev_order_id) and  (rn >1)) then 'Same_day_repeat'
			 else 'diffeent_day_repeat'
			 end as repeat_flag
			 from ranking_data z
		) qaas_injected_alias
