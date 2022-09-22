with source as (

    select * from {{ source('imdb', 'title_episodes') }}

),

renamed as (

    select
        tconst as title_id,
        parent_tconst as parent_title_id,
        season_number,
        episode_number
    from source

)

select * from renamed