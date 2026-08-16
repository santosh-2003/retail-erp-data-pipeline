select
    s.transaction_id,
    s.transaction_date,
    c.customer_id,
    p.product_id,
    st.store_id,
    e.employee_id,
    s.quantity,
    p.unit_price,
    s.discount_percent,
    (s.quantity * p.unit_price) * (1 - coalesce(s.discount_percent, 0) / 100.0) as net_revenue,
    s.payment_method,
    s.order_status
from {{ ref('stg_sales') }} s
left join {{ ref('dim_customer') }} c on s.customer_id = c.customer_id
left join {{ ref('dim_products') }} p on s.product_id = p.product_id
left join {{ ref('dim_stores') }} st on s.store_id = st.store_id
left join {{ ref('dim_employees') }} e on s.employee_id = e.employee_id
where s.transaction_date is not null
  and not s.is_negative_quantity
