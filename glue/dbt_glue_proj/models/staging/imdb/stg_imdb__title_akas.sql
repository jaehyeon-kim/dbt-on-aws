with source as (

    select * from {{ source('imdb', 'title_akas') }}

),

renamed as (

    select
        titleid as title_id,
        ordering,
        title,
        region,
        language,
        types,
        attributes,
        isoriginaltitle as is_original_title
    from source
    where titleid <> 'titleId'

)

select * from renamed