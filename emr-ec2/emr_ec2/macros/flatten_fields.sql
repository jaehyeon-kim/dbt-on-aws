{% macro flatten_fields(model, field_name, id_field_name) %}
    select 
        {{ id_field_name }} as id,
        explode(split({{ field_name }}, ',')) as field
    from {{ model }}
{% endmacro %}
