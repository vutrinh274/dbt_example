{{ config(materialized='table') }}

SELECT
    md5(p.product_key) as product_key,
    p.product_name,
    p.product_sku,
    p.product_color,
    ps.subcategory_name,
    pc.category_name,
FROM {{ ref("stg_products") }} p
LEFT JOIN {{ ref("stg_product_subcategories") }} ps
    ON p.product_subcategory_key = ps.product_subcategory_key
LEFT JOIN {{ ref("stg_product_categories") }} pc
    ON ps.product_category_key = pc.product_category_key