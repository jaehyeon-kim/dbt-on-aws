with flattened as (
    {{ flatten_fields(ref('stg_imdb__title_crews'), 'directors', 'title_id') }}
)

select 
    id as title_id, 
    field as name_id
from flattened
order by id
