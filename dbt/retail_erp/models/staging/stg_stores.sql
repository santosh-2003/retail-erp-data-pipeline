with source as (
    select * from {{ source('raw', 'raw_stores') }}
),
cleaned as (
    select
        trim(store_id) as store_id,
        trim(store_name) as store_name,
        initcap(trim(city)) as city,
        trim(manager) as manager,
        nullif(trim(opening_date), '')::date as opening_date
    from source
)
select * from cleaned
