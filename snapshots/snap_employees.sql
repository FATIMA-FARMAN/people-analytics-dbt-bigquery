{% snapshot snap_employees %}

{{
  config(
    unique_key='employee_id',
    strategy='check',
    check_cols='all',
    invalidate_hard_deletes=True
  )
}}

select
  *
from {{ ref('int_employees') }}

{% endsnapshot %}
