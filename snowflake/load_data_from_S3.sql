-- product_categories
CREATE OR REPLACE TABLE dbt_raw.public.product_categories (
    product_category_key STRING,
    category_name STRING
);
COPY INTO dbt_raw.public.product_categories
  FROM @my_s3_stage/AdventureWorks_Product_Categories.csv;

-- product_subcategories
CREATE OR REPLACE TABLE dbt_raw.public.product_subcategories (
    product_subcategory_key STRING,
    subcategory_name STRING,
    product_category_Key STRING
);
COPY INTO dbt_raw.public.product_subcategories
  FROM @my_s3_stage/AdventureWorks_Product_Subcategories.csv;

-- products

CREATE OR REPLACE TABLE dbt_raw.public.products (
    product_key STRING,
    product_subcategory_key STRING,
    product_sku STRING,
    product_name STRING,
    model_name STRING,
    product_description STRING,
    product_color STRING,
    product_size STRING,
    product_style STRING,
    product_cost FLOAT,
    product_price FLOAT
);
COPY INTO dbt_raw.public.products
  FROM @my_s3_stage/AdventureWorks_Products.csv;

 -- sales
CREATE OR REPLACE TABLE dbt_raw.public.sales (
    order_date STRING,
    stock_date STRING,
    order_number STRING,
    product_key STRING,
    customer_key STRING,
    territory_key STRING,
    order_line_item INT,
    order_quantity INT
);
COPY INTO dbt_raw.public.sales
  FROM @my_s3_stage/AdventureWorks_Sales_2017.csv;

-- territories
CREATE OR REPLACE TABLE dbt_raw.public.territories (
    sales_territory_key STRING,
    region STRING,
    country STRING,
    continent STRING
);
COPY INTO dbt_raw.public.territories
  FROM @my_s3_stage/AdventureWorks_Territories.csv;