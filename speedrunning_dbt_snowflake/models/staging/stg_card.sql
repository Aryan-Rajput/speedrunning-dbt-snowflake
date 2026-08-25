with source as (
    select * from {{ source('raw', 'card') }}
),
renamed as (
    select
        card_id,
        disp_id,
        lower(type) as card_type,
        cast(to_date(split_part(issued::varchar, ' ', 1), 'YYMMDD') as date) as card_issued_date
    from source
)
select * from renamed