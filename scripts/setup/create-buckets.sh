#!/bin/bash

###############################################################################
# AWS S3 Bucket Creation Script
# 
# Description: Creates primary, DR, and logs S3 buckets with proper configuration
# Author: Mohammad Elgizawy
# Date: 2025
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TIMESTAMP=$(date +%s)
PRIMARY_REGION="us-east-1"
DR_REGION="eu-west-1"

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print section header
print_header() {
    echo ""
    echo "=============================================="
    print_message "$BLUE" "$1"
    echo "=============================================="
    echo ""
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_message "$RED" "❌ Error: AWS CLI is not installed"
        echo "Please install AWS CLI: https://aws.amazon.com/cli/"
        exit 1
    fi
    print_message "$GREEN" "✅ AWS CLI is installed"
}

# Function to check AWS credentials
check_aws_credentials() {
    if ! aws sts get-caller-identity &> /dev/null; then
        print_message "$RED" "❌ Error: AWS credentials not configured"
        echo "Please run: aws configure"
        exit 1
    fi
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    print_message "$GREEN" "✅ AWS credentials configured (Account: $ACCOUNT_ID)"
}

# Function to generate unique bucket name
generate_bucket_name() {
    local base_name=$1
    local region=$2
    echo "${base_name}-${region}-${TIMESTAMP}"
}

# Function to create S3 bucket
create_bucket() {
    local bucket_name=$1
    local region=$2
    local description=$3
    
    print_message "$YELLOW" "��� Creating bucket: $bucket_name in $region..."
    
    # Create bucket
    if [ "$region" == "us-east-1" ]; then
        # us-east-1 doesn't need LocationConstraint
        aws s3 mb s3://$bucket_name --region $region
    else
        aws s3api create-bucket \
            --bucket $bucket_name \
            --region $region \
            --create-bucket-configuration LocationConstraint=$region
    fi
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Bucket created successfully: $bucket_name"
        
        # Add tags
        aws s3api put-bucket-tagging \
            --bucket $bucket_name \
            --tagging "TagSet=[
                {Key=Project,Value=AWS-S3-Static-Website-Hosting},
                {Key=Environment,Value=Production},
                {Key=ManagedBy,Value=Script},
                {Key=Purpose,Value=$description}
            ]"
        
        print_message "$GREEN" "✅ Tags applied to $bucket_name"
    else
        print_message "$RED" "❌ Failed to create bucket: $bucket_name"
        exit 1
    fi
}

# Function to enable versioning
enable_versioning() {
    local bucket_name=$1
    
    print_message "$YELLOW" "��� Enabling versioning on $bucket_name..."
    
    aws s3api put-bucket-versioning \
        --bucket $bucket_name \
        --versioning-configuration Status=Enabled
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Versioning enabled on $bucket_name"
    else
        print_message "$RED" "❌ Failed to enable versioning on $bucket_name"
    fi
}

# Function to save bucket names to config file
save_config() {
    local primary_bucket=$1
    local dr_bucket=$2
    local logs_bucket=$3
    
    CONFIG_FILE="bucket-config.txt"
    
    cat > $CONFIG_FILE << EOF
# AWS S3 Bucket Configuration
# Generated: $(date)

PRIMARY_BUCKET=$primary_bucket
PRIMARY_REGION=$PRIMARY_REGION

DR_BUCKET=$dr_bucket
DR_REGION=$DR_REGION

LOGS_BUCKET=$logs_bucket
LOGS_REGION=$PRIMARY_REGION

# Website Endpoint
WEBSITE_URL=http://${primary_bucket}.s3-website-${PRIMARY_REGION}.amazonaws.com
