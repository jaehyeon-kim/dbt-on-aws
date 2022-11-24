with source as (

    select * from {{ source('imdb', 'title_episode') }}

),

renamed as (

    select
        tconst as title_id,
        parenttconst as parent_title_id,
        cast(seasonnumber as int) season_number,
        cast(episodenumber as int) as episode_number
    from source

)

select * from renamed