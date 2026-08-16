SELECT store_id, store_name, city, manager, opening_date
FROM {{ ref('stg_stores')   }}