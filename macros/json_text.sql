{% macro json_text(json_col, key) -%}
  JSON_VALUE({{ json_col }}, '$.{{ key }}')
{%- endmacro %}