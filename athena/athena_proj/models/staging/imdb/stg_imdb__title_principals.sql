with source as (

    select * from {{ source('imdb', 'title_principals') }}

),

renamed as (

    select
        tconst as title_id,
        ordering,
        nconst as name_id,
        category,
        job,
        replace(replace(replace(characters, '"', ''), '[', ''), ']', '') as characters
    from source

)

select * from renamed