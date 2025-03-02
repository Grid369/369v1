#!/bin/bash

# Variables
REPO_URL="https://github.com/Grid369/369v1"
RAW_URL="https://raw.githubusercontent.com/Grid369/369v1/main/lambda/requirements.txt"
TEMP_DIR="/tmp/369v1"

# Function to check if a URL exists
url_exists() {
    if curl --output /dev/null --silent --head --fail "$1"; then
        return 0  # URL exists
    else
        return 1  # URL does not exist
    fi
}

# Step 1: Check if requirements.txt exists on GitHub
echo "Checking if requirements.txt exists on GitHub..."
if url_exists "$RAW_URL"; then
    echo "requirements.txt found! Installing dependencies..."
    pip install -r "$RAW_URL"
else
    echo "ERROR: requirements.txt not found at $RAW_URL"
    echo "Creating a default requirements.txt file..."

    # Create a default requirements.txt
    echo "boto3" > requirements.txt

    echo "Upload requirements.txt to your GitHub repository at:"
    echo "$REPO_URL/tree/main/lambda"
    echo "Then re-run this script."
    exit 1
fi

# Step 2: Upgrade pip (optional)
echo "Upgrading pip..."
python -m pip install --upgrade pip

# Step 3: Verify installation
echo "Verifying installed packages..."
pip freeze

echo "Done!"
