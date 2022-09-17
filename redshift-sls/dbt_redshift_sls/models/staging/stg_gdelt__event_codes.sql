{{ 
    config(
        materialized='view',
        bind=False
    )
}}
with source as (
    select * from {{ source('gdelt_external', 'event_code') }}
),
renamed as (
    select
        code,
        description
    from source
)
select * from renamed