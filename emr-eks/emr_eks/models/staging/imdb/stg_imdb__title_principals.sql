with source as (

    select * from {{ source('imdb', 'title_principals') }}

),

renamed as (

    select
        tconst as title_id,
        ordering,
        nconst as name_id,
        category,
        case when job = 'N' then null else job end as job,
        case when characters = 'N' then null else characters end as characters        
    from source
    where tconst <> 'tconst'

)

select 
    title_id,
    ordering,
    name_id,
    category,
    job,
    replace(replace(replace(characters, '"', ""), "[", ""), "]", "") as characters 
from renamed