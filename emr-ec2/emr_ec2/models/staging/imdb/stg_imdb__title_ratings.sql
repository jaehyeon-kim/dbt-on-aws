with source as (

    select * from {{ source('imdb', 'title_ratings') }}

),

renamed as (

    select
        tconst as title_id,
        averagerating as average_rating,
        numvotes as num_votes
    from source

)

select * from renamed