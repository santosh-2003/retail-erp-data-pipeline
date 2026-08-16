select
    c.customer_id,
    c.customer_name,
    c.city,
    c.loyalty_status,
    count(distinct f.transaction_id) as total_orders,
    sum(f.net_revenue) as lifetime_revenue,
    round(avg(f.net_revenue), 2) as avg_order_value,
    max(f.transaction_date) as last_purchase_date
from {{ ref('fact_sales') }} f
join {{ ref('dim_customer') }} c on f.customer_id = c.customer_id
where f.order_status = 'Completed'
group by 1, 2, 3, 4
order by lifetime_revenue desc
