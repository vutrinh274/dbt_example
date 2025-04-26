# ETL Pipelines with Orchestra

Welcome to **ETL Pipelines with Orchestra**. This project demonstrates a simple ETL pipeline with the following 5 steps:

1. Getting your Credential
2. Fork and clone the repo to your prefer directory
3. Upload Adventures CSV files to S3 Bucket
4. Create a Staging Area and Load Data from S3 Bucket to Snowflake
5. Configure dbt connection
6. Use dbt to Create Staging Models
7. Use dbt to Create Curated Models (Dimensional - Fact)
8. Orchestrate the Pipeline with Orchestra

---

## Prerequisite: What You Will Need
To successfully follow this project, you should have exposure to **dbt** for data modeling, **Snowflake** as the data warehouse platform, and **boto3** for interacting with AWS services like S3. Additionally, basic proficiency in **Python** is essential, including how to manage **virtual environments** (`.venv`) and set **environment variables**. Familiarity with writing **SQL queries** and understanding how dbt structures models (staging, curated) will help you navigate and customize the pipeline effectively.

## Step 1: Getting Your Credentials

Before running the pipeline, you'll need to gather credentials for **GitHub**, **Snowflake**, and **AWS S3**. Here’s how you can set them up:

---

### Step 1.1 GitHub Fine-Grained Personal Access Tokens

For secure integration with **Orchestra**, you’ll need to generate **Fine-grained personal access tokens** from your GitHub account.

Generate **three tokens** (can be the same or different):
- `orchestra_dbt`
- `orchestra_dbt_prod`
- `orchestra_python`

> **How to create a token:**
1. Go to [GitHub Tokens Settings](https://github.com/settings/tokens).
2. Click **Generate new token** (fine-grained).
3. Set permissions based on your repo needs (at least **repo** and **workflow** access).
4. Copy the token immediately (you won’t be able to see it again).

---

### Step 1.2 Snowflake Credentials

You’ll need a **Snowflake** account to load and model data.

> **How to create a Snowflake account:**
1. Sign up for a **free trial** at [Snowflake Free Trial](https://signup.snowflake.com/).
2. After signing up, note down the following:
   - `SNOWFLAKE_ACCOUNT`: Your account identifier (e.g., `abc12345.us-east-1`).
   - `SNOWFLAKE_USER`: Your Snowflake username.
   - `SNOWFLAKE_PASSWORD`: Your Snowflake password.
   - `SNOWFLAKE_ROLE`: The role you’ll use (e.g., `ACCOUNTADMIN`).
   - `SNOWFLAKE_SCHEMA`: The schema where your data will be loaded (create one if needed).

---

### Step 1.3 S3 Bucket Credentials

To upload data to **AWS S3**, you’ll need an **AWS account**.

> **How to get AWS credentials:**
1. Sign in to the [AWS Console](https://aws.amazon.com/).
2. Navigate to **IAM** > **Users** > Create or select a user.
3. Under **Security credentials**, create **Access keys**:
   - `AWS_KEY_ID`: Your access key ID.
   - `AWS_SECRET_KEY`: Your secret access key.
4. Find your region:
   - `AWS_REGION`: e.g., `us-east-1`.
5. Create an **S3 bucket** (or use an existing one):
   - `S3_BUCKET`: Your bucket name.
   - `S3_PREFIX`: Optional subfolder path in the bucket (can be left as `""`).

---

## Step 2: Fork and Clone the Repository

You will need your own copy of the project to configure and run the ETL pipeline. This step ensures that you can work independently without affecting the original repository.

---

### Step 2.1: Fork the Repository

1. Go to the original repository: [dbt_example](https://github.com/vutrinh274/dbt_example).
2. Click the **Fork** button in the top-right corner of the page.
3. Select your GitHub account as the destination.

This creates a personal copy of the repository under your GitHub account.

---

### Step 2.2: Clone the Forked Repository

Clone the forked repository to your local machine so you can make edits and run the project.

#### Linux / MacOS:
```bash
git clone https://github.com/your-username/dbt_example.git  # Replace 'your-username' with your GitHub username
cd dbt_example                                               # Navigate into the cloned project directory
```

#### Windows (Command Prompt or PowerShell):
```cmd
git clone https://github.com/your-username/dbt_example.git  # Replace 'your-username' with your GitHub username
cd dbt_example                                              # Navigate into the cloned project directory
```
---

## Step 3: Upload Data into S3 Bucket

In this step, you'll upload the **AdventureWorks CSV files** into an **S3 bucket** to serve as the data source for your ETL pipeline.

### Prerequisite: What You'll Need
- **S3 Bucket**: The destination where your data will be stored.
- **AWS Credentials**:  
  - `AWS_KEY_ID`: Your AWS access key ID.  
  - `AWS_SECRET_KEY`: Your AWS secret access key.
- **AWS Region**:  
  - `AWS_REGION`: The region where your S3 bucket resides (e.g., `us-east-1` for N. Virginia).
- **Bucket Details**:  
  - `S3_BUCKET`: The name of your S3 bucket.  
  - `S3_PREFIX`: The folder path inside your bucket (can be left as `""` for the root directory).

**Example Configuration:**

```bash
AWS_KEY_ID=AKIAXXXXXXXX
AWS_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION=us-east-1
S3_BUCKET=my-adventureworks-bucket
S3_PREFIX=data/adventureworks/
```

---

### Step 3.1: Create a Virtual Environment and Install Dependencies

Creating a **virtual environment** (`.venv`) helps isolate project dependencies from your system Python environment. This ensures compatibility and prevents version conflicts between different projects.

#### Linux / MacOS:
```bash
python3 -m venv .venv          # Create a virtual environment in the .venv folder
source .venv/bin/activate      # Activate the virtual environment
pip install -r python-requirements.txt  # Install project dependencies from python-requirements.txt
```

#### Windows:
```bash
python -m venv .venv            # Create a virtual environment in the .venv folder
.venv\Scripts\activate          # Activate the virtual environment
pip install -r python-requirements.txt  # Install project dependencies from python-requirements.txt
```

---

### Step 3.2: Export Your AWS Credentials to Environment Variables

Exporting **AWS credentials** as environment variables keeps sensitive information out of your code and allows tools like **boto3** to securely access AWS services (like S3). These variables tell Python scripts and AWS CLI how to authenticate with AWS.

#### Linux / MacOS:
```bash
export AWS_KEY_ID=your_aws_key_id          # Set your AWS access key ID
export AWS_SECRET_KEY=your_aws_secret_key  # Set your AWS secret access key
export AWS_REGION=your_aws_region          # Set your AWS region (e.g., us-east-1)
export S3_BUCKET=your_s3_bucket            # Set your S3 bucket name
export S3_PREFIX=your_s3_prefix            # Set your S3 prefix (subfolder path or leave empty "")
```

#### Windows (Command Prompt):
```cmd
set AWS_KEY_ID=your_aws_key_id
set AWS_SECRET_KEY=your_aws_secret_key
set AWS_REGION=your_aws_region
set S3_BUCKET=your_s3_bucket
set S3_PREFIX=your_s3_prefix
```

#### Windows (PowerShell):
```powershell
$env:AWS_KEY_ID="your_aws_key_id"
$env:AWS_SECRET_KEY="your_aws_secret_key"
$env:AWS_REGION="your_aws_region"
$env:S3_BUCKET="your_s3_bucket"
$env:S3_PREFIX="your_s3_prefix"
```

---

### Step 3.3: Run the Python Pipeline!

This step runs the **Python script** that uploads your CSV files to S3 using **boto3**. Make sure your virtual environment is activated and your environment variables are properly set before running this script.

#### Linux / MacOS / Windows:
```bash
cd python/                      # Change directory into the Python folder
python upload_to_s3.py           # Run the Python script to upload files to S3
```

If successful, the script will print logs like the following for each file uploaded:

```
Uploading AdventureWorks_Product_Categories.csv to s3://new-british-airline/AdventureWorks_Product_Categories.csv (will overwrite if exists)...
Uploading AdventureWorks_Sales_2017.csv to s3://new-british-airline/AdventureWorks_Sales_2017.csv (will overwrite if exists)...
Uploading AdventureWorks_Product_Subcategories.csv to s3://new-british-airline/AdventureWorks_Product_Subcategories.csv (will overwrite if exists)...
Uploading AdventureWorks_Territories.csv to s3://new-british-airline/AdventureWorks_Territories.csv (will overwrite if exists)...
Uploading AdventureWorks_Products.csv to s3://new-british-airline/AdventureWorks_Products.csv (will overwrite if exists)...
✅ All CSV files uploaded (overwritten if existed).
```

---

## Step 4: Create a Staging Area and Load Data from S3 Bucket to Snowflake

---

### Step 4.1: Create STAGE: `my_s3_stage`

A **stage** in Snowflake is a pointer to an external or internal location where files are stored. In this case, we're creating an **external stage** that points to your **S3 bucket** where the CSV files were uploaded.

By creating a stage, we enable Snowflake to read files directly from S3 using SQL `COPY INTO` commands. This simplifies loading data into Snowflake tables and allows for efficient integration between Snowflake and AWS.

#### SQL Command:
```sql
CREATE OR REPLACE STAGE my_s3_stage
URL = 's3://<your_bucket_name>/'
CREDENTIALS = (
  AWS_KEY_ID = '<your_aws_key_id>'
  AWS_SECRET_KEY = '<your_aws_secret_key>'
)
FILE_FORMAT = (
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
);
```

> Replace `<your_bucket_name>`, `<your_aws_key_id>`, and `<your_aws_secret_key>` with your actual AWS credentials and S3 bucket name.

This stage configuration tells Snowflake how to authenticate with AWS, where to find the files, and how to parse the CSV format.

---

### Step 4.2: Create Database `<your_db_name>` and Schemas `dev` and `prod`

In a typical production environment, **dev** and **prod** would reside in separate databases or even different servers to ensure proper separation of development and production data. However, for simplicity in this project, we will create **two schemas** (`dev` and `prod`) within the same database.

I have chosen the database name **ORCHESTRA**, but you can name it whatever you prefer.

#### SQL Commands:
```sql
CREATE OR REPLACE DATABASE orchestra;  -- Create the ORCHESTRA database
USE orchestra;                          -- Switch to the ORCHESTRA database
CREATE SCHEMA dev;                      -- Create the development schema
CREATE SCHEMA prod;                     -- Create the production schema
```
This structure allows us to separate **development** and **production** data models within the same database, making it easier to manage in a learning environment.

---

### Step 4.3: Load Data from S3 to Snowflake

In this step, you'll create **staging tables** in Snowflake and load data from the **S3 bucket** (where we previously uploaded the CSV files). This prepares the data for further transformation with **dbt**.

> **Note:**  
Feel free to change the **database name** (`orchestra`) and **schema name** (`dev`) to match your setup. The following example assumes the database is `orchestra` and the schema is `dev`.

These commands copy data directly from your **S3 bucket** (via Snowflake stage `@my_s3_stage`) into Snowflake tables.

#### SQL Commands:
```sql
-- product_categories
CREATE OR REPLACE TABLE orchestra.dev.product_categories (
    product_category_key STRING,
    category_name STRING
);
COPY INTO orchestra.dev.product_categories
  FROM @my_s3_stage/AdventureWorks_Product_Categories.csv;

-- product_subcategories
CREATE OR REPLACE TABLE orchestra.dev.product_subcategories (
    product_subcategory_key STRING,
    subcategory_name STRING,
    product_category_key STRING
);
COPY INTO orchestra.dev.product_subcategories
  FROM @my_s3_stage/AdventureWorks_Product_Subcategories.csv;

-- products
CREATE OR REPLACE TABLE orchestra.dev.products (
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
COPY INTO orchestra.dev.products
  FROM @my_s3_stage/AdventureWorks_Products.csv;

-- sales
CREATE OR REPLACE TABLE orchestra.dev.sales (
    order_date STRING,
    stock_date STRING,
    order_number STRING,
    product_key STRING,
    customer_key STRING,
    territory_key STRING,
    order_line_item INT,
    order_quantity INT
);
COPY INTO orchestra.dev.sales
  FROM @my_s3_stage/AdventureWorks_Sales_2017.csv;

-- territories
CREATE OR REPLACE TABLE orchestra.dev.territories (
    sales_territory_key STRING,
    region STRING,
    country STRING,
    continent STRING
);
COPY INTO orchestra.dev.territories
  FROM @my_s3_stage/AdventureWorks_Territories.csv;
```

This process **loads the raw CSV data from S3 into Snowflake tables** in the **dev schema**, preparing them for transformation into staging and curated models via **dbt**.

## Step 5: Configure dbt connection
In this step, we willl create Staging models from data that just been loaded to snowflake from S3. Staging models in dbt are typically model that do minor transformation to the source data, but let's configure dbt first

### Step 5.1: Configure dbt `profiles.yml`

Navigate into the cloned repository folder:

```bash
cd dbt_example  # Move into the dbt_example project directory
```

Inside this directory, you'll find a `profiles.yml` file (or you may need to create one inside `~/.dbt/` depending on your dbt version). This file contains the **connection settings** that dbt uses to connect to **Snowflake**.

Fill in your **Snowflake credentials** and configuration details as shown below:

```yml
dbt_example:
  outputs:
    dev:
      type: snowflake
      account: your_account       # e.g., abc12345.us-east-1
      user: your_user             # Your Snowflake username
      password: your_password     # Your Snowflake password
      role: your_role             # e.g., ACCOUNTADMIN
      database: your_database     # e.g., orchestra
      warehouse: your_warehouse   # Your Snowflake warehouse
      schema: your_schema         # e.g., dev
      threads: 1
      client_session_keep_alive: False

    prod:
      type: snowflake
      account: your_account
      user: your_user
      password: your_password
      role: your_role
      database: your_database
      warehouse: your_warehouse
      schema: your_schema         # e.g., prod
      threads: 1
      client_session_keep_alive: False
  target: dev
```

> **Note:**  
You can reuse the same database and warehouse, but set **different schemas** for `dev` and `prod` (e.g., `dev` and `prod` schemas in the **orchestra** database).

---

### Step 5.2: Test dbt Connection with `dbt debug`

After configuring `profiles.yml`, test your connection to Snowflake using dbt. Make sure you are in the `dbt example` directory.

```bash
dbt debug  # Run this inside the dbt_example directory
```

If everything is configured correctly, dbt will confirm that it can successfully connect to your Snowflake account.
If you see `All checks passed!`, you are good to go! 

## Step 6: Use dbt to Create Staging Models

Now that your **dbt connection** is verified, you can start building your **staging models**. In **dbt**, models can be organized and tagged for easier execution. 

**Staging models** in dbt are used to **clean, rename, and standardize raw data** from source tables (like those loaded from S3). They serve as an **intermediate layer** between raw data and curated models, making data easier to work with and consistent across your transformations.

Before running the staging models, make sure to **update the database and schema names** in the `landing/schema.yml` file to match your setup (e.g., change them to `orchestra` and `dev`).

Here, we will build only the models tagged as **`staging`** by running:

```bash
dbt build -s tag:staging
```

This command will:
- **Run** models tagged with `staging`.
- **Test** those models (if tests are defined).
- **Materialize** them in the **dev schema** in Snowflake.

> **Tip:**  
You can check which models are tagged with `staging` by looking at the `tags` section in each model's `.sql` file inside the `models/staging/` directory.  

If the terminal says `Completed successfully`, that means the dbt models have been successfully materialized. You can log into Snowflake and **verify the changes** under the **dev schema**.


## Step 7: Use dbt to Create Curated Models

After building your **staging models**, the next step is to create **curated models**. In **dbt**, models are often tagged and organized for easier execution. 

**Curated models** are the final **business-ready tables**, such as **fact** and **dimension** tables. These models are built on top of **staging models** and are structured specifically for reporting, analytics, and other downstream use cases. They apply business logic, aggregations, and transformations needed to produce clean, reliable datasets.

To build only the models tagged as **`curated`**, run:

```bash
dbt build -s tag:curated
```

This command will:
- **Run** models tagged with `curated`.
- **Test** those models (if tests are defined).
- **Materialize** them in the **dev schema** in Snowflake.

> **Tip:**  
You can check which models are tagged with `curated` by looking at the `tags` section in each model’s `.sql` file inside the `models/marts/` or `models/curated/` directory.  

If the terminal says `Completed successfully`, it means the **curated models** have been materialized in Snowflake. You can log into Snowflake and verify the tables under your **dev schema**.

## Step 8: Orchestrate the Pipeline with Orchestra

Now that you’ve successfully run each step locally, it’s time to **orchestrate the entire ETL pipeline** using **Orchestra**. Orchestration allows you to automate and schedule these steps, ensuring they run in the correct order without manual intervention.

A detailed tutorial for setting up Orchestra can be found here:  
[Let’s Use Orchestra to Build an End-to-End Data Pipeline](https://vutr.substack.com/p/lets-use-orchestra-to-build-an-end)

> **Note:**  
In the tutorial, the database used is called `dbt_raw` with schema `public`.  
For this project, feel free to **adjust the database and schema names** (e.g., `orchestra` with `dev` or `prod` schemas) to match your setup.

With Orchestra, you'll be able to:
- **Automate** data loading from S3 to Snowflake.
- **Run dbt transformations** (staging and curated models).
- **Schedule** and **monitor** your ETL pipeline seamlessly.