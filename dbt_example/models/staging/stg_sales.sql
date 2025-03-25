{{ config(materialized='table') }}

SELECT 
    TO_DATE('1/6/2017', 'MM/DD/YYYY') AS order_date,
    TO_DATE('10/28/2003', 'MM/DD/YYYY') AS stock_date,
    order_number,
    product_key,
    customer_key,
    territory_key,
    order_quantity
FROM {{ source('adventures', 'sales') }}
