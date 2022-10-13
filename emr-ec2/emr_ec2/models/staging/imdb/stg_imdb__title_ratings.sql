with source as (

    select * from {{ source('imdb', 'title_ratings') }}

),

renamed as (

    select
        tconst as title_id,
        cast(averagerating as float) as average_rating,
        cast(numvotes as int) as num_votes
    from source
    where tconst <> 'tconst'

)

select * from renamed