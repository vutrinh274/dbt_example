{{ config(materialized='table') }}

SELECT *

FROM {{ source('adventures', 'territories') }}

