-- models/staging/stg_account.sql

with source as (

    select * from {{ source('raw', 'account') }}

),
renamed as (

    select
        account_id,
        district_id,
        cast(to_date(date::varchar, 'YYMMDD') as date) as account_created_date,
        case
            when frequency = 'POPLATEK MESICNE' then 'monthly'
            when frequency = 'POPLATEK TYDNE' then 'weekly'
            when frequency = 'POPLATEK PO OBRATU' then 'after_transaction'
        end as frequency
    from source

)

select * from renamed