{{ config(materialized='table') }}

SELECT
    DISTINCT
    md5(country) as country_key,
    country,
    continent
FROM {{ ref("stg_territories") }}