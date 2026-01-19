{{ config(materialized="view") }}

with base as (

    select
        event_date,
        from_stage,
        to_stage,
        entered_candidates,
        safe_divide(progressed_candidates, entered_candidates) as conversion_rate
    from {{ ref('fct_funnel_conversion_daily') }}

),

ranked as (

    select
        event_date,
        from_stage,
        to_stage,
        conversion_rate,
        row_number() over (
            partition by event_date
            order by conversion_rate asc
        ) as rn
    from base
    where entered_candidates > 0

)

select
    event_date,
    from_stage,
    to_stage,
    conversion_rate
from ranked
where rn = 1

