{{ config(materialized='table') }}

SELECT
    s.order_date,
    s.order_number,
    md5(s.product_key) as product_key,
    md5(t.country) as country_key,
    (s.order_quantity * p.product_price) as revenue,
    (s.order_quantity * p.product_cost) as cost,
    (s.order_quantity * p.product_price) - (s.order_quantity * p.product_cost) as profit,
FROM {{ ref("stg_sales") }} s
LEFT JOIN {{ ref("stg_products") }} p
    ON s.product_key = p.product_key
LEFT JOIN {{ ref("stg_territories") }} t
    ON s.territory_Key = t.sales_territory_key