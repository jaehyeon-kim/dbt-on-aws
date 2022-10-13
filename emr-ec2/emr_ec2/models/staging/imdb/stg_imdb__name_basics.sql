with source as (

    select * from {{ source('imdb', 'name_basics') }}

),

renamed as (

    select
        nconst as name_id,
        primaryname as primary_name,
        cast(birthyear as int) as birth_year,
        cast(deathyear as int) as death_year,
        case when primaryprofession in ('', 'N') then null 
             else primaryprofession 
        end as primary_profession,
        case when knownfortitles in ('', 'N') then null 
             else knownfortitles 
        end as known_for_titles
    from source
    where nconst <> 'nconst'

)

select * from renamed