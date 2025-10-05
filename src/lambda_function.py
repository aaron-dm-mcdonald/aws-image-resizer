import os
import uuid
from urllib.parse import unquote_plus
import boto3
from PIL import Image

# Initialize S3 client for interacting with S3 buckets
s3_client = boto3.client('s3')

def resize_image(image_path, resized_path):
    """
    Resize an image to half its original dimensions.
    
    Args:
        image_path: Path to the original image file
        resized_path: Path where the resized image will be saved
    """
    with Image.open(image_path) as image:
        # Reduce each dimension by half (width/2, height/2)
        image.thumbnail(tuple(x / 2 for x in image.size))
        image.save(resized_path)

def lambda_handler(event, context):
    """
    Lambda handler triggered by S3 ObjectCreated events.
    Downloads the uploaded image, resizes it, and uploads to destination bucket.
    
    Args:
        event: S3 event containing bucket and object information
        context: Lambda context object (unused)
    """
    # Process each S3 event record (typically one per invocation)
    for record in event['Records']:
        # Extract bucket name and object key from the event
        bucket = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])  # Decode URL-encoded key
        
        # Create temporary file paths in Lambda's /tmp directory
        tmpkey = key.replace('/', '')  # Remove slashes for local filename
        download_path = '/tmp/{}{}'.format(uuid.uuid4(), tmpkey)  # Unique name to avoid conflicts
        upload_path = '/tmp/resized-{}'.format(tmpkey)
        
        # Download the original image from S3
        s3_client.download_file(bucket, key, download_path)
        
        # Resize the image
        resize_image(download_path, upload_path)
        
        # Upload the resized image to the destination bucket
        s3_client.upload_file(
            upload_path, 
            os.getenv('DESTINATION_BUCKETNAME'),  # Target bucket from environment variable
            'resized-{}'.format(key)  # Prefix filename with 'resized-'
        )