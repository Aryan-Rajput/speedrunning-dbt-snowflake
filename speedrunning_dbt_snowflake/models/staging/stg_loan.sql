with source as (
    select * from {{ source('raw', 'loan') }}
),
renamed as (
    select
        loan_id,
        account_id,
        cast(to_date(date::varchar, 'YYMMDD') as date) as loan_date,
        amount as loan_amount,
        duration as loan_duration_months,
        payments as monthly_payment,
        status as loan_status_code
    from source
)
select * from renamed