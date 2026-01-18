{{ config(materialized='view') }}

with base as (

    select
        date(event_ts) as event_date,
        stage,
        candidate_id
    from {{ ref('fct_hiring_funnel_incremental') }}

),

-- ordered stage mapping (edit labels here if your stages differ)
stage_order as (

    select 'Applied' as stage, 1 as stage_num union all
    select 'Screen', 2 union all
    select 'Interview', 3 union all
    select 'Offer', 4 union all
    select 'Hired', 5

),

staged as (

    select
        b.event_date,
        b.stage,
        so.stage_num,
        b.candidate_id
    from base b
    join stage_order so
        on b.stage = so.stage

),

entered as (

    -- candidates who entered each stage on that day
    select
        event_date,
        stage,
        stage_num,
        count(distinct candidate_id) as entered_candidates
    from staged
    group by 1,2,3

),

progressed as (

    -- candidates who reached the next stage on the same day
    select
        s1.event_date,
        s1.stage as from_stage,
        s1.stage_num as from_stage_num,
        s2.stage as to_stage,
        count(distinct s1.candidate_id) as progressed_candidates
    from staged s1
    join staged s2
        on s1.candidate_id = s2.candidate_id
       and s1.event_date = s2.event_date
       and s2.stage_num = s1.stage_num + 1
    group by 1,2,3,4

)

select
    e.event_date,
    e.stage as from_stage,
    p.to_stage,
    e.entered_candidates,
    coalesce(p.progressed_candidates, 0) as progressed_candidates,

    safe_divide(coalesce(p.progressed_candidates, 0), e.entered_candidates) as conversion_rate,
    1 - safe_divide(coalesce(p.progressed_candidates, 0), e.entered_candidates) as dropoff_rate

from entered e
left join progressed p
    on e.event_date = p.event_date
   and e.stage = p.from_stage
   and e.stage_num = p.from_stage_num
order by 1, e.stage_num

