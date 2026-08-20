with source as (
    select * from {{ source('raw', 'district') }}
),
renamed as (
    select
        A1 as district_id,
        A2 as district_name,
        A3 as region,
        A4 as no_of_inhabitants,
        A5 as no_of_municipalities_lt499,
        A6 as no_of_municipalities_500_1999,
        A7 as no_of_municipalities_2000_9999,
        A8 as no_of_municipalities_gt10000,
        A9 as no_of_cities,
        A10 as ratio_urban_inhabitants,
        A11 as average_salary,
        A12 as unemployment_rate_95,
        A13 as unemployment_rate_96,
        A14 as entrepreneurs_per_1000_inhabitants,
        A15 as no_of_crimes_95,
        A16 as no_of_crimes_96
    from source
)
select * from renamed