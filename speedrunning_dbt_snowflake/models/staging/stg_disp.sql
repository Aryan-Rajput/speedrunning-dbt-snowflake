with source as (
    select * from {{ source('raw', 'disp') }}
),
renamed as (
    select
        disp_id,
        client_id,
        account_id,
        type
    from source
)

select * from renamed

-- not added changes because this is a staging model and we don't want to track changes at this level
-- also no labguage changge needed alredy in english