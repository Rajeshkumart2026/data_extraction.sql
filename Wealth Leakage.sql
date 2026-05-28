WITH MonthlyMetrics AS (
    SELECT 
        account_id,
        DATE_TRUNC(txn_date, MONTH) as month,
        SUM(balance) as avg_bal,
        COUNT(transaction_id) as txn_count,
        SUM(CASE WHEN category = 'Investment' THEN amount ELSE 0 END) as invest_amt
    FROM ledger
    GROUP BY 1, 2
),
TrendAnalysis AS (
    SELECT 
        *,
           (avg_bal - LAG(avg_bal) OVER(PARTITION BY account_id ORDER BY month)) / 
            NULLIF(LAG(avg_bal) OVER(PARTITION BY account_id ORDER BY month), 0) as bal_velocity,
           LAG(txn_count, 1) OVER(PARTITION BY account_id ORDER BY month) as prev_month_activity
    FROM MonthlyMetrics
)
SELECT 
    t.*,
    u.tenure_days, u.city_tier, u.is_churned -- Target Variable
FROM TrendAnalysis t
JOIN user_dim u ON t.account_id = u.account_id
WHERE month = '2026-03-01'
