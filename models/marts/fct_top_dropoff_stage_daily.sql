{{ config(materialized="view") }}

with dropoff as (
    select
        event_date,
        from_stage,
        stage_dropoff_rate
    from {{ ref('fct_stage_dropoff_daily') }}
),

ranked as (
    select
        event_date,
        from_stage as top_dropoff_stage,
        stage_dropoff_rate as top_dropoff_rate,
        row_number() over (
            partition by event_date
            order by stage_dropoff_rate desc
        ) as rn
    from dropoff
)

select
    event_date,
    top_dropoff_stage,
    top_dropoff_rate
from ranked
where rn = 1

