-- models/intermediate/int_account_owners.sql
-- the 3 way join is dependent on disp as there are the type tha can be used to filter the other 2 tables. 
--The other 2 tables are not dependent on each other and can be joined in any order.
with disp as (
    select * from {{ ref('stg_disp') }}
    where type = 'OWNER'
),

client as (
    select * from {{ ref('stg_client') }}
),

account as (
    select * from {{ ref('stg_account') }}
),

joined as (

    select
        disp.disp_id,
        account.account_id,
        account.district_id as account_district_id,
        account.account_created_date,
        account.frequency,
        client.client_id,
        client.district_id as client_district_id,
        client.birth_date,
        client.client_gender

    from disp
    left join client on disp.client_id = client.client_id
    left join account on disp.account_id = account.account_id

)
select * from joined