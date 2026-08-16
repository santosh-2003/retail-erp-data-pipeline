with source as (
    select * from {{ source('raw', 'raw_sales') }}
),
cleaned as (
    select
        trim(transaction_id) as transaction_id,
        safe_to_date(trim(transaction_date)) as transaction_date,
        trim(customer_id) as customer_id,
        trim(product_id) as product_id,
        trim(store_id) as store_id,
        trim(employee_id) as employee_id,
        nullif(trim(quantity), '')::int as quantity,
        (nullif(trim(quantity), '')::int < 0) as is_negative_quantity,
        nullif(trim(discount_percent), '')::numeric as discount_percent,
        initcap(trim(payment_method)) as payment_method,
        initcap(trim(order_status)) as order_status
    from source
),
deduped as (
    select distinct * from cleaned
)
select * from deduped
