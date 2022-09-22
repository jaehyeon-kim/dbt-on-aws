with recursive cte (id, idx, field) as (
    {{ flatten_fields(ref('stg_imdb__title_crews'), 'writers', 'title_id') }}
)

select 
    id as title_id, 
    field as writer
from cte
order by id