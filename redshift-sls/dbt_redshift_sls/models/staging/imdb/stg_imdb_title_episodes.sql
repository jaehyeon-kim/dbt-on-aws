with source as (

    select * from {{ source('imdb', 'title_episodes') }}

),

renamed as (

    select
        tconst as title_id,
        parent_tconst,
        season_number,
        episode_number
    from source

)

select * from renamed