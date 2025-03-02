#!/bin/bash

# Variables
LAMBDA_FUNCTION_NAME="AIManagerFunction"
LAMBDA_ROLE_ARN="arn:aws:iam::123456789012:role/lambda-execution-role"  # Replace with your Lambda execution role ARN
DEPLOYMENT_PACKAGE="lambda-deployment-package.zip"

# Step 1: Install dependencies into a package directory
echo "Installing dependencies..."
mkdir -p lambda_package
pip install -r requirements.txt -t lambda_package

# Step 2: Add Lambda function code to the package
echo "Adding Lambda function code..."
cp lambda_function.py lambda_package/

# Step 3: Create a deployment package
echo "Creating deployment package..."
cd lambda_package
zip -r ../$DEPLOYMENT_PACKAGE .
cd ..

# Step 4: Deploy to AWS Lambda
echo "Deploying to AWS Lambda..."
aws lambda create-function \
    --function-name $LAMBDA_FUNCTION_NAME \
    --zip-file fileb://$DEPLOYMENT_PACKAGE \
    --handler lambda_function.lambda_handler \
    --runtime python3.9 \
    --role $LAMBDA_ROLE_ARN

echo "Deployment complete!"
