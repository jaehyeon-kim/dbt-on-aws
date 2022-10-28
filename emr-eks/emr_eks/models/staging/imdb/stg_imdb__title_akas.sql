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
        case when types = 'N' then null 
             else types 
        end as types,
        case when attributes = 'N' then null 
             else attributes 
        end as attributes,
        isoriginaltitle as is_original_title
    from source
    where titleid <> 'titleId'

)

select * from renamed