with source as (

    select * from {{ source('imdb', 'title_akas') }}

),

renamed as (

    select
        title_id,
        ordering,
        title,
        region,
        language,
        types,
        attributes,
        is_original_title
    from source

)

select * from renamed