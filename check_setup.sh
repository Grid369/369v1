#!/bin/bash

# Define required files and directories
REQUIRED_FILES=("README.md" "requirements.txt" "install_dependencies.sh" "deploy_lambda.sh" "lambda_function.py")
REQUIRED_DIRS=("lambda")

# Function to check if a file exists
check_file() {
    if [ -f "$1" ]; then
        echo "File $1 is present."
    else
        echo "File $1 is missing!"
    fi
}

# Function to check if a directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo "Directory $1 is present."
    else
        echo "Directory $1 is missing!"
    fi
}

# Check required files
echo "Checking required files..."
for file in "${REQUIRED_FILES[@]}"; do
    check_file "$file"
done

# Check required directories
echo "Checking required directories..."
for dir in "${REQUIRED_DIRS[@]}"; do
    check_dir "$dir"
done

# Check Python dependencies
echo "Checking Python dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "requirements.txt is missing! Cannot install Python dependencies."
fi

echo "Check complete."
