-- models/intermediate/int_loan_risk_flags.sql

with loan as (
    select * from {{ ref('stg_loan') }}
),

flagged as (

    select
        loan_id as loan_id,
        account_id as account_id,
        loan_date as loan_date,
        loan_amount as loan_amount,
        loan_duration_months as loan_duration_months,
        monthly_payment as monthly_payment,
        loan_status_code,
        -- kept the value is defaulted as when its B it means the loan is finished but the full amount is not paid 
        -- idk how this works but thatsthe reason somehow
        -- now for the value of D the loan amount is running and the complete ammont is still remaining so 
        --  its in defaulted state 
        case
            when loan_status_code in ('B', 'D') then true
            else false
        end as is_defaulted,

        case
            when loan_status_code in ('A', 'C') then true
            else false
        end as is_active

    from loan
)

select * from flagged