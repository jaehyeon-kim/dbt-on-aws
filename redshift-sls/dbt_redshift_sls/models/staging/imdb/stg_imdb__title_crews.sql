with source as (

    select * from {{ source('imdb', 'title_crews') }}

),

renamed as (

    select
        tconst as title_id,
        directors,
        writers
    from source

)

select * from renamed