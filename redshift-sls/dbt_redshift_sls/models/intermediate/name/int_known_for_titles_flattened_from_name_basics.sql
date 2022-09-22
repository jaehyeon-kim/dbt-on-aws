with recursive cte (id, idx, field) as (
    {{ flatten_fields(ref('stg_imdb__name_basics'), 'known_for_titles', 'name_id') }}
)

select 
    id as name_id, 
    field as known_for_title
from cte
order by id