with source as (

    select * from {{ source('raw', 'client') }}

),

renamed as (

    select
        client_id,
        district_id,
        floor((birth_number % 10000) / 100) as month_raw,
        case
            when floor((birth_number % 10000) / 100) > 12 then 'F'
            else 'M'
        end as client_gender,

        date_from_parts(
            1900 + floor(birth_number / 10000),
            case
                when floor((birth_number % 10000) / 100) > 12
                    then floor((birth_number % 10000) / 100) - 50
                else floor((birth_number % 10000) / 100)
            end,
            birth_number % 100
        ) as birth_date
    from source
)

select
    client_id,
    district_id,
    client_gender,
    birth_date
from renamed