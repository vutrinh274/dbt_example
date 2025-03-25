{{ config(materialized='table') }}

SELECT *

FROM {{ source('adventures', 'product_subcategories') }}