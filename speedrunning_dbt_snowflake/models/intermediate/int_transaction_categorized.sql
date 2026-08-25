-- models/intermediate/int_transaction_categorized.sql

with trans as (
    select * from {{ ref('stg_trans') }}
)

select
    trans_id,
    account_id,
    trans_date,
    trans_type,
    trans_operation,
    trans_amount,
    balance_after_trans,
    trans_purpose,
    bank,
    account,

    -- flag loan repayments so downstream marts can exclude them from
    -- generic transaction volume sums (they're already counted in the loan table)
    case
        when trans_purpose = 'loan_payment' then true
        else false
    end as is_loan_repayment

from trans