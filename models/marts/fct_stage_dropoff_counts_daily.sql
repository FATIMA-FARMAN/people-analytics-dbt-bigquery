{{ config(materialized="view") }}

with base as (

    select
        event_date,
        from_stage as stage,
        entered_candidates,
        progressed_candidates
    from {{ ref('fct_funnel_conversion_daily') }}

),

agg as (

    select
        event_date,
        stage,
        sum(entered_candidates) as total_entered_candidates,
        sum(progressed_candidates) as total_progressed_candidates,
        sum(entered_candidates) - sum(progressed_candidates) as dropped_candidates,
        safe_divide(
            sum(entered_candidates) - sum(progressed_candidates),
            sum(entered_candidates)
        ) as dropoff_rate
    from base
    group by 1,2

)

select
    event_date,
    stage,
    total_entered_candidates,
    total_progressed_candidates,
    dropped_candidates,
    dropoff_rate
from agg
where total_entered_candidates > 0
order by event_date desc, dropped_candidates desc
