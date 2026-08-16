with source as (
    select * from {{ source('raw', 'raw_products') }}
),
cleaned as (
    select
        trim(product_id) as product_id,
        initcap(trim(product_name)) as product_name,
        initcap(trim(category)) as category,
        initcap(trim(subcategory)) as subcategory,
        initcap(trim(brand)) as brand,
        nullif(trim(unit_price), '')::numeric as unit_price,
        trim(supplier) as supplier
    from source
)
select * from cleaned
