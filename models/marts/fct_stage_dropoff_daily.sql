{{ config(materialized="view") }}

with events as (
    select
        cast(event_ts as timestamp) as event_ts,
        date(cast(event_ts as timestamp)) as event_date,
        cast(candidate_id as int64) as candidate_id,
        lower(cast(stage as string)) as stage
    from {{ ref("fct_hiring_funnel_incremental") }}
),

stage_first_seen as (
    select
        candidate_id,
        stage,
        min(event_ts) as first_seen_ts
    from events
    group by 1, 2
),

stage_chain as (
    select
        date(first_seen_ts) as event_date,
        candidate_id,
        stage as from_stage,
        lead(stage) over (
            partition by candidate_id
            order by first_seen_ts
        ) as to_stage
    from stage_first_seen
),

agg as (
    select
        event_date,
        from_stage,
        count(distinct candidate_id) as entered_candidates,
        count(distinct case when to_stage is not null then candidate_id end) as progressed_candidates
    from stage_chain
    group by 1, 2
)

select
    event_date,
    from_stage,
    entered_candidates,
    progressed_candidates,
    safe_divide(progressed_candidates, entered_candidates) as stage_conversion_rate,
    1 - safe_divide(progressed_candidates, entered_candidates) as stage_dropoff_rate
from agg

