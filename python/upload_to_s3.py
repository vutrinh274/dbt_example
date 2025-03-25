from pathlib import Path
import os
import boto3

AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_REGION = os.getenv('AWS_REGION')
S3_BUCKET = os.getenv('S3_BUCKET')
S3_PREFIX = os.getenv('S3_PREFIX')
BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DATA_FOLDER= BASE_DIR + "/adventures_data"

s3 = boto3.client(
    "s3",
    region_name=AWS_REGION,
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
)

def upload_csv_files():
    print (DATA_FOLDER)
    local_path = Path(DATA_FOLDER)
    csv_files = local_path.glob("*.csv")

    for file_path in csv_files:
        file_name = file_path.name
        s3_key = f"{S3_PREFIX}{file_name}".replace("//", "/")
        
        print(f"Uploading {file_name} to s3://{S3_BUCKET}/{s3_key} (will overwrite if exists)...")
        s3.upload_file(str(file_path), S3_BUCKET, s3_key)
    
    print("✅ All CSV files uploaded (overwritten if existed).")

if __name__ == "__main__":
    upload_csv_files()