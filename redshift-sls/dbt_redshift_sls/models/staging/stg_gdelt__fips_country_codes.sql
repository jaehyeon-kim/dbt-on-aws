{{ 
    config(
        materialized='view',
        bind=False
    )
}}
with source as (
    select * from {{ source('gdelt_external', 'fips_country_code') }}
),
renamed as (
    select
        code,
        label
    from source
)
select * from renamed