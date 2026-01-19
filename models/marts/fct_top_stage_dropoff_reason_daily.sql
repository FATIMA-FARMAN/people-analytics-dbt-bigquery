{{ config(materialized="view") }}

with base as (
    select
        event_date,
        top_dropoff_stage as stage,
        top_dropoff_rate as dropoff_rate
    from {{ ref('fct_top_dropoff_stage_daily') }}
),

ranked as (
    select
        event_date,
        stage as top_stage_dropoff,
        dropoff_rate as top_dropoff_rate,
        row_number() over (
            partition by event_date
            order by dropoff_rate desc
        ) as rn
    from base
    where dropoff_rate is not null
)

select
    event_date,
    top_stage_dropoff,
    top_dropoff_rate
from ranked
where rn = 1
