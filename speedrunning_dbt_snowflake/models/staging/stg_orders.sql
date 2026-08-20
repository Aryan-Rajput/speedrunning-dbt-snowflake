with source as (
    select * from {{ source('raw', 'orders') }}
),
renamed as (
    select
        order_id,
        account_id,
        bank_to,
        account_to,
        amount as order_amount,
        case k_symbol
            when 'POJISTNE' then 'insurance_payment'
            when 'SIPO' then 'household_payment'
            when 'LEASING' then 'leasing_payment'
            when 'UVER' then 'loan_payment'
            else 'unspecified'
        end as order_purpose
    from source
)
select * from renamed