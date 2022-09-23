{{
    config(
        schema='analytics',
        materialized='table',
        sort='genre',
        dist='genre'
    )
}}

with titles as (

    select * from {{ ref('stg_imdb__title_basics') }}

),

genres as (

    select
        title_id,
        genre
    from {{ ref('int_genres_flattened_from_title_basics') }}

),

final as (

    select
        g.genre,
        t.title_id,
        t.title_type,
        t.primary_title,
        t.original_title,
        t.is_adult,
        t.start_year,
        t.end_year,
        t.runtime_minutes
    from genres g
    join titles t on g.title_id = t.title_id
)

select * from final