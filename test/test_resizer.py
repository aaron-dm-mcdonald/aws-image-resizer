#!/usr/bin/env python3

import boto3
import subprocess
import time
from pathlib import Path
from PIL import Image

def get_terraform_output(output_name):
    result = subprocess.run(["terraform", "output", "-raw", output_name], capture_output=True, text=True)
    return result.stdout.strip()

def main():
    script_dir = Path(__file__).parent
    test_image = script_dir / "test_image.png"
    resized_image = script_dir / "resized-test_image.png"
    
    s3 = boto3.client('s3')
    
    source_bucket = get_terraform_output("s3_source_bucket_name")
    output_bucket = get_terraform_output("s3_output_bucket_name")
    
    with Image.open(test_image) as img:
        original = img.size
    
    print(f"uploading {original[0]}x{original[1]}")
    s3.upload_file(str(test_image), source_bucket, "test_image.png")
    
    print("waiting for lambda")
    for _ in range(15):
        time.sleep(2)
    
    s3.download_file(output_bucket, "resized-test_image.png", str(resized_image))
    
    with Image.open(resized_image) as img:
        resized = img.size
    
    print(f"result: {original[0]}x{original[1]} -> {resized[0]}x{resized[1]}")

if __name__ == "__main__":
    main()