{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'iterable') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('iterable_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("iterable_database", target.database) }}' || '.'|| '{{ var("iterable_schema", "iterable") }}' as source_relation
{% endif %}

{%- endmacro %}