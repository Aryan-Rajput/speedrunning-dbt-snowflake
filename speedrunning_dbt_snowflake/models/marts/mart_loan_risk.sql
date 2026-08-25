-- models/marts/mart_loan_risk.sql

with loan as (
    select * from {{ ref('int_loan_risk_flags') }}
),

owners as (
    select * from {{ ref('int_account_owners') }}
),

repayments as (
    select
        account_id,
        count(*) as uver_payment_count
    from {{ ref('int_transaction_categorized') }}
    where is_loan_repayment = true
    group by account_id
),

final as (

    select
        loan.loan_id,
        loan.account_id,
        owners.client_id,
        owners.client_gender,
        owners.birth_date,
        loan.loan_date,
        loan.loan_amount,
        loan.loan_duration_months,
        loan.monthly_payment,
        loan.loan_status_code,
        loan.is_defaulted,
        loan.is_active,
        coalesce(repayments.uver_payment_count, 0) as payments_made,

        -- expected payments = duration in months, since payments are monthly
        loan.loan_duration_months as payments_expected,

        -- ratio, guarding against divide-by-zero
        case
            when loan.loan_duration_months > 0
            then round(coalesce(repayments.uver_payment_count, 0)::float / loan.loan_duration_months, 2)
            else null
        end as payment_completion_ratio

    from loan
    left join owners on loan.account_id = owners.account_id
    left join repayments on loan.account_id = repayments.account_id

)

select * from final