{% macro try_to_ts(col) -%}
  COALESCE(
    SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST({{ col }} AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S%Ez',   CAST({{ col }} AS STRING)),
    SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',      CAST({{ col }} AS STRING))
  )
{%- endmacro %}