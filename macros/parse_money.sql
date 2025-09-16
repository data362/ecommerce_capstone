{% macro parse_money(col) -%}
  SAFE_CAST(REGEXP_REPLACE(TRIM(CAST({{ col }} AS STRING)), r'[^0-9.\-]', '') AS NUMERIC)
{%- endmacro %}