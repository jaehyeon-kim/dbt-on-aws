{% macro flatten_fields(model, field_name, id_field_name) %}
    with subset as (
        select 
            {{ id_field_name }} as id, 
            regexp_count({{ field_name }}, ',') + 1 AS num_fields,
            {{ field_name }} as fields
        from {{ model }}
    )
    select
        id,
        1 as idx,
        split_part(fields, ',', 1) as field
    from subset
    union all
    select
        s.id,
        idx + 1 as idx,
        split_part(s.fields, ',', idx + 1)
    from subset s
    join cte on s.id = cte.id
    where idx < num_fields
{% endmacro %}
