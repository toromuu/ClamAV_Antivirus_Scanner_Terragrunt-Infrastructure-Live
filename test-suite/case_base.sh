 
#!/bin/bash

# Array of test file URLs to download from https://www.eicar.org/download-anti-malware-testfile/
urls=(
    "https://secure.eicar.org/eicarcom2.zip"
    "https://secure.eicar.org/eicar_com.zip"
    "https://secure.eicar.org/eicar.com.txt"
    "https://secure.eicar.org/eicar.com"
    "https://fegalaz.usc.es/~gamallo/aulas/lingcomputacional/corpus/quijote-es.txt"
)

# S3 bucket name
bucket_name="s3://quarantine-clamav-antivirus-scanner-test"

# Download and upload function
# Download and upload function
function download_and_upload {
    url="$1"
    file_name="$(basename "$url")"
 
    # Download the file
    echo "Downloading $url..."
    curl -s -o "$file_name" "$url"
    
    # Upload the file to S3
    echo "Uploading $file_name to S3..."
    aws s3 cp "$file_name" "$bucket_name"
    
    # Remove the downloaded file
    rm "$file_name"
}

# Loop through the URLs and call the download_and_upload function
for url in "${urls[@]}"; do
    download_and_upload "$url"
done
