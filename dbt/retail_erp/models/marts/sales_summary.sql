select
    st.city,
    date_trunc('month', f.transaction_date) as sales_month,
    count(distinct f.transaction_id) as total_orders,
    sum(f.net_revenue) as total_revenue,
    round(avg(f.net_revenue), 2) as avg_order_value
from {{ ref('fact_sales') }} f
join {{ ref('dim_stores') }} st on f.store_id = st.store_id
where f.order_status = 'Completed'
group by 1, 2
order by 1, 2
