with recursive cte (id, idx, field) as (
    {{ flatten_fields(ref('stg_imdb__title_crews'), 'directors', 'title_id') }}
)

select 
    id as title_id, 
    field as director
from cte
order by id
