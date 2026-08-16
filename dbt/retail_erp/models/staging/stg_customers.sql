with source as (
    select * from {{ source('raw', 'raw_customers') }}
),
cleaned as (
    select
        trim(customer_id) as customer_id,
        initcap(trim(customer_name)) as customer_name,
        lower(trim(gender)) as gender,
        nullif(trim(age), '')::int as age,
        lower(trim(email)) as email,
        nullif(trim(phone), '') as phone,
        initcap(trim(city)) as city,
        trim(state) as state,
        trim(country) as country,
        nullif(trim(signup_date), '')::date as signup_date,
        initcap(trim(loyalty_status)) as loyalty_status
    from source
)
select * from cleaned
