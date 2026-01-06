{% snapshot snap_hr_employees_scd2_demo %}
{{
  config(
    target_schema='main',
    unique_key='employee_id',
    strategy='check',
    check_cols=['department','title']
  )
}}
select * from {{ ref('hr_employees_scd2_demo') }}
{% endsnapshot %}
