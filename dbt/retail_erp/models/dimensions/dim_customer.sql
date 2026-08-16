select
    customer_id,
    customer_name,
    gender,
    age,
    email,
    phone,
    city,
    state,
    country,
    signup_date,
    loyalty_status
from {{ ref('stg_customers') }}
