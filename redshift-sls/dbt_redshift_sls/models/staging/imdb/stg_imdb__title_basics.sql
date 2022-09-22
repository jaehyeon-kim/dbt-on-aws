with source as (

    select * from {{ source('imdb', 'title_basics') }}

),

renamed as (

    select
        tconst as title_id,
        title_type,
        primary_title,
        original_title,
        is_adult,
        start_year::int as start_year,
        end_year::int as end_year,
        runtime_minutes::int as runtime_minutes,
        genres
    from source

)

select * from renamed