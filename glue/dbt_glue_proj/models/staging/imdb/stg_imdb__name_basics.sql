with source as (

    select * from {{ source('imdb', 'name_basics') }}

),

renamed as (

    select
        nconst as name_id,
        primaryname as primary_name,
        cast(birthyear as int) as birth_year,
        cast(deathyear as int) as death_year,
        case when primaryprofession = '' then null 
             else primaryprofession 
        end as primary_profession,
        knownfortitles as known_for_titles
    from source
    where nconst <> 'nconst'

)

select * from renamed