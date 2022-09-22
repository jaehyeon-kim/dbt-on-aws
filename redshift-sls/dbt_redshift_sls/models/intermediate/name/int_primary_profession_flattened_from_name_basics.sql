with recursive cte (id, idx, field) as (
    {{ flatten_fields(ref('stg_imdb__name_basics'), 'primary_profession', 'name_id') }}
)

select 
    id as name_id, 
    field as primary_profession
from cte
order by id