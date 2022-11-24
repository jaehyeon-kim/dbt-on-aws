{% macro flatten_fields(model, field_name, id_field_name) %}
    select
        {{ id_field_name }} as id,
        field
    from {{ model }}
    cross join unnest(split({{ field_name }}, ',')) as x(field)
{% endmacro %}
