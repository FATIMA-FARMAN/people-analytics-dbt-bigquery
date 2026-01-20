{{ config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='sync_all_columns'
) }}

with src as (

    select
        cast(event_id as int64) as event_id,
        cast(candidate_id as int64) as candidate_id,
        cast(stage as string) as stage,
        cast(event_ts as timestamp) as event_ts
    from {{ ref('hiring_events_incremental_demo') }}

)

select * from src

{% if is_incremental() %}
where event_ts > (select max(event_ts) from {{ this }})
{% endif %}

