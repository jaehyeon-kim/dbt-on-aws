with source as (

    select * from {{ source('imdb', 'name_basics') }}

),

renamed as (

    select
        nconst as name_id,
        primary_name,
        birth_year,
        death_year,
        case when primary_profession = '' then null 
             else primary_profession 
        end as primary_profession,
        known_for_titles
    from source

)

select * from renamed