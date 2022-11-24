with source as (

    select * from {{ source('imdb', 'title_basics') }}

),

renamed as (

    select
        tconst as title_id,
        titletype as title_type,
        primarytitle as primary_title,
        originaltitle as original_title,
        cast(isadult as boolean) as is_adult,
        cast(startyear as int) as start_year,
        cast(endyear as int) as end_year,
        cast(runtimeminutes as int) as runtime_minutes,
        genres
    from source

)

select * from renamed