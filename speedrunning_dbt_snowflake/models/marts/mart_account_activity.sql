-- models/marts/mart_account_activity.sql

with trans as (
    select * from {{ ref('int_transaction_categorized') }}
),

account as (
    select * from {{ ref('stg_account') }}
),

monthly_activity as (

    select
        account_id,
        date_trunc('month', trans_date) as activity_month,
        count(*) as transaction_count,
        sum(case when trans_type = 'credit' then trans_amount else 0 end) as total_credits,
        sum(case when trans_type = 'withdrawal' then trans_amount else 0 end) as total_withdrawals,
        sum(case when is_loan_repayment then trans_amount else 0 end) as total_loan_repayments,
        avg(balance_after_trans) as avg_balance

    from trans
    group by account_id, date_trunc('month', trans_date)

),

final as (

    select
        monthly_activity.*,
        account.frequency,
        account.district_id

    from monthly_activity
    left join account on monthly_activity.account_id = account.account_id

)

select * from final