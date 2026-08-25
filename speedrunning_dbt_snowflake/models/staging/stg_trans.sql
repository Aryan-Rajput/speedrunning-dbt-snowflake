with source as (
    select * from {{ source('raw', 'trans') }}
),
renamed as (
    select
        trans_id,
        account_id,
        cast(to_date(date::varchar, 'YYMMDD') as date) as trans_date,
        case type
            when 'PRIJEM' then 'credit'
            when 'VYDAJ' then 'withdrawal'
            when 'VYBER' then 'withdrawal'
            else 'unspecified_' || type
        end as trans_type,
        case operation
            when 'VYBER KARTOU' then 'credit_card_withdrawal'
            when 'VKLAD' then 'cash_deposit'
            when 'PREVOD Z UCTU' then 'collection_from_bank'
            when 'VYBER' then 'cash_withdrawal'
            when 'PREVOD NA UCET' then 'remittance_to_bank'
            else 'unspecified'
        end as trans_operation,
        amount as trans_amount,
        balance as balance_after_trans,
        case k_symbol
            when 'UROK' then 'interest_credited'
            when 'POJISTNE' then 'insurance_payment'
            when 'UVER' then 'loan_payment'
            when 'DUCHOD' then 'pension'
            when 'SIPO' then 'household_payment'
            when 'SLUZBY' then 'statement_fee'
            when 'SANKC. UROK' then 'sanction_interest'
            else null
        end as trans_purpose,
        bank,
        account
    from source
)
select * from renamed