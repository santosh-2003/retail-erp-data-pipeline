with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
cleaned as (
    select
        trim(employee_id) as employee_id,
        trim(employee_name) as employee_name,
        trim(store_id) as store_id,
        initcap(trim(position)) as position,
        nullif(trim(hire_date), '')::date as hire_date,
        nullif(trim(salary), '')::numeric as salary
    from source
)
select * from cleaned
