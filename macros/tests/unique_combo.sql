{% test unique_combo(model, combination_of_columns) %}

select
  {{ combination_of_columns | join(', ') }},
  count(*) as cnt
from {{ model }}
group by {{ combination_of_columns | join(', ') }}
having count(*) > 1

{% endtest %}
