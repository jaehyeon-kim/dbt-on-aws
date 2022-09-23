{{
    config(
        schema='analytics',
        materialized='table',
        sort='name_id',
        dist='name_id'
    )
}}

with names as (

    select * from {{ ref('stg_imdb__name_basics') }}

),

directed as (

    select
        name_id,
        count(title_id) as num_directed
    from {{ ref('int_directors_flattened_from_title_crews') }}
    group by name_id

),

writted as (

    select
        name_id,
        count(title_id) as num_written
    from {{ ref('int_writers_flattened_from_title_crews') }}
    group by name_id

),

final as (

    select
        n.name_id,
        n.primary_name,
        n.birth_year,
        n.death_year,
        n.primary_profession,
        n.known_for_titles,
        regexp_count(n.primary_profession, ',') + 1 AS num_primary_professions,
        regexp_count(n.known_for_titles, ',') + 1 AS num_known_for_titles,
        d.num_directed,
        w.num_written
    from names as n
    left join directed as d on n.name_id = d.name_id
    left join writted as w on n.name_id = w.name_id

)

select * from final