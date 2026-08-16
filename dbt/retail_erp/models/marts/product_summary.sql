select
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    sum(f.quantity) as total_units_sold,
    sum(f.net_revenue) as total_revenue,
    count(distinct f.transaction_id) as total_orders
from {{ ref('fact_sales') }} f
join {{ ref('dim_products') }} p on f.product_id = p.product_id
where f.order_status = 'Completed'
group by 1, 2, 3, 4
order by total_revenue desc
