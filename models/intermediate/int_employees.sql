with stg as (
  select *
  from {{ ref('stg_employees') }}
)

select
  employee_id,
  department,
  location,
  job_level,
  manager_id,
  hire_date,

  -- placeholders so downstream models don't break (optional)
  cast(null as string) as email,
  cast(null as string) as role,
  cast(null as date)   as termination_date,

  -- since we don't have termination_date, we cannot compute real active status
  true as is_active

from stg


