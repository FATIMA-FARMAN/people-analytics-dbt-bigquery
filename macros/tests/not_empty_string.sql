{% test not_empty_string(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} is not null
  and trim(cast({{ column_name }} as string)) = ''

{% endtest %}
