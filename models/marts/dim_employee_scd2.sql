select
  employee_id,

  -- keep all columns from the snapshot (including SCD2 timestamps + attributes)
  * except (employee_id),

  -- friendly aliases
  dbt_valid_from as valid_from,
  dbt_valid_to   as valid_to,
  dbt_valid_to is null as is_current

from {{ ref('snap_employees') }}
