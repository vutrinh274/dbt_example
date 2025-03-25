{{ config(materialized='table') }}

SELECT *

FROM {{ source('adventures', 'products') }}