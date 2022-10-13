with source as (

    select * from {{ source('imdb', 'title_crew') }}

),

renamed as (

    select
        tconst as title_id,
        case when directors = 'N' then null else directors end as directors,
        case when writers = 'N' then null else writers end as writers
    from source
    where tconst <> 'tconst'

)

select * from renamed