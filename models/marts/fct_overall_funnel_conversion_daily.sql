{{ config(materialized="view") }}

with base as (

    select
        event_date,
        sum(entered_candidates) as total_entered_candidates,
        sum(progressed_candidates) as total_progressed_candidates
    from {{ ref('fct_funnel_conversion_daily') }}
    group by 1

)

select
    event_date,
    total_entered_candidates,
    total_progressed_candidates,
    safe_divide(total_progressed_candidates, total_entered_candidates) as overall_conversion_rate
from base
where total_entered_candidates > 0

