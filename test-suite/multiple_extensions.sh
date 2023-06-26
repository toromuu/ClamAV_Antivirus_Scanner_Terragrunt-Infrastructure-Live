#!/bin/bash

# Array of file URLs to download
urls=(
    "https://filesamples.com/samples/video/mp4/sample_960x400_ocean_with_audio.mp4"
    "https://filesamples.com/samples/audio/mp3/sample4.mp3"
    "https://filesamples.com/samples/document/pdf/sample2.pdf"
    "https://filesamples.com/samples/document/ppt/sample2.ppt"
    "https://filesamples.com/samples/document/csv/sample4.csv"
    "https://filesamples.com/samples/document/doc/sample1.doc"
    "https://filesamples.com/samples/document/xls/sample2.xls"
    "https://filesamples.com/samples/document/txt/sample1.txt"
    "https://filesamples.com/samples/image/jpg/sample_640%C3%97426.jpg"
    "https://filesamples.com/samples/image/bmp/sample_640%C3%97426.bmp"
    "https://filesamples.com/samples/image/png/sample_640%C3%97426.png"
    "https://buenosaires.gob.ar/areas/educacion/quijote/pdf/don_quijote_de_la_mancha.zip"
    "https://getsamplefiles.com/download/tar/sample-1.tar"
)

# S3 bucket name
bucket_name="s3://quarantine-clamav-antivirus-scanner-test"

# Download and upload function
function download_and_upload {
    url="$1"
    file_name="$(basename "$url")"
    extension="${file_name##*.}"
    
    # Download the file
    echo "Downloading $url..."
    curl -s -o "$file_name" "$url"
    
    # Upload the file to S3
    echo "Uploading $file_name to S3..."
    aws s3 cp "$file_name" "$bucket_name/"
    
    # Remove the downloaded file
    rm "$file_name"
}

# Loop through the URLs and call the download_and_upload function
for url in "${urls[@]}"; do
    download_and_upload "$url"
done
