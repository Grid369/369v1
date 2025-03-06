#!/bin/bash
set -e

# Function to check if jq is installed
check_jq_installed() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq to proceed."
    echo "On Ubuntu: sudo apt-get install jq"
    echo "On macOS: brew install jq"
    exit 1
  fi
}

# Check if jq is installed
check_jq_installed

# Prompt for necessary inputs
echo "Please provide the following details:"
read -p "AWS Connection ARN: " CONNECTION_ARN
read -p "GitHub Repository (owner/repo): " GITHUB_REPO
read -p "AWS Region (e.g., us-east-1): " AWS_REGION
read -sp "GitHub Personal Access Token: " GITHUB_TOKEN
echo

# Extract region from ARN if not provided
if [ -z "$AWS_REGION" ]; then
  AWS_REGION=$(echo $CONNECTION_ARN | cut -d: -f4)
  echo "Extracted AWS Region from ARN: $AWS_REGION"
fi

# Step 1: Verify AWS Connection Status
echo "Step 1: Checking AWS Connection Status..."
STATUS=$(aws codestar-connections get-connection --connection-arn $CONNECTION_ARN --region $AWS_REGION --query 'Connection.Status' --output text 2>/dev/null)
if [ "$STATUS" != "AVAILABLE" ]; then
  echo "❌ Connection is not available. Status: $STATUS"
  echo "Please wait a few minutes or recreate the connection in the AWS Console."
  exit 1
else
  echo "✅ Connection is available."
fi

# Step 2: Check GitHub App Installation
echo "Step 2: Verifying GitHub App Installation..."
INSTALLATION=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_REPO/installation" | jq -r '.app_slug')
if [ "$INSTALLATION" != "aws-connector-for-github" ]; then
  echo "❌ AWS Connector for GitHub is not installed on $GITHUB_REPO."
  echo "Please install it from: https://github.com/apps/aws-connector-for-github"
  exit 1
else
  echo "✅ AWS Connector for GitHub is installed."
fi

# Step 3: Test the Connection by Listing Pipelines
echo "Step 3: Testing the Connection..."
PIPELINES=$(aws codepipeline list-pipelines --region $AWS_REGION 2>/dev/null)
if [ $? -ne 0 ]; then
  echo "❌ Failed to list pipelines. This could be due to permission issues or connection problems."
  echo "Ensure you have the necessary permissions for AWS CodePipeline."
else
  echo "✅ Successfully listed pipelines. Connection is working."
fi

# Step 4: Check IAM Permissions for the Current User
echo "Step 4: Checking IAM Permissions..."
CURRENT_USER=$(aws sts get-caller-identity --query 'Arn' --output text | cut -d/ -f2)
POLICIES=$(aws iam list-attached-user-policies --user-name $CURRENT_USER --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null)
if echo $POLICIES | grep -q "AWSCodeStarConnectionsFullAccess"; then
  echo "✅ AWSCodeStarConnectionsFullAccess policy is attached."
else
  echo "❌ Missing AWSCodeStarConnectionsFullAccess policy."
  echo "Please attach the policy or contact your AWS administrator."
fi

# Step 5: Reminder to Check AWS Service Health
echo "Step 5: Don't forget to check the AWS Service Health Dashboard for any outages in $AWS_REGION."
echo "Visit: https://status.aws.amazon.com/"

echo "All automated checks completed!"
