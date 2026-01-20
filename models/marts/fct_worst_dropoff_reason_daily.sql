{{ config(materialized='view') }}

with base as (
    select
        event_date,
        stage,
        concat('Dropoff at ', stage) as dropoff_reason,
        dropped_candidates as dropoff_candidates
    from {{ ref('fct_stage_dropoff_counts_daily') }}
    where dropped_candidates > 0
),

ranked as (
    select
        event_date,
        stage,
        concat('Dropoff at ', stage) as dropoff_reason,
        dropoff_candidates,
        row_number() over (
            partition by event_date
            order by dropoff_candidates desc
        ) as rn
    from base
)

select
    event_date,
    stage,
    dropoff_reason,
    dropoff_candidates
from ranked
where rn = 1

