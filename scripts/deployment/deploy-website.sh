#!/bin/bash

###############################################################################
# AWS S3 Website Deployment Script
# 
# Description: Deploys website files to S3 and configures static website hosting
# Author: Mohammad Elgizawy
# Date: 2025
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${1}${2}${NC}"
}

print_header() {
    echo ""
    echo "=============================================="
    print_message "$BLUE" "$1"
    echo "=============================================="
    echo ""
}

# Load configuration
load_config() {
    CONFIG_FILE="../../bucket-config.txt"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_message "$RED" "❌ Error: bucket-config.txt not found"
        echo "Please run create-buckets.sh first"
        exit 1
    fi
    
    source $CONFIG_FILE
    print_message "$GREEN" "✅ Configuration loaded"
    echo "   Bucket: $PRIMARY_BUCKET"
    echo "   Region: $PRIMARY_REGION"
}

# Check if website files exist
check_website_files() {
    WEBSITE_DIR="../../website-files"
    
    if [ ! -d "$WEBSITE_DIR" ]; then
        print_message "$RED" "❌ Error: website-files directory not found"
        exit 1
    fi
    
    if [ ! -f "$WEBSITE_DIR/index.html" ]; then
        print_message "$RED" "❌ Error: index.html not found in website-files/"
        exit 1
    fi
    
    print_message "$GREEN" "✅ Website files found"
}

# Upload files to S3
upload_files() {
    print_message "$YELLOW" "��� Uploading files to S3..."
    
    cd $WEBSITE_DIR
    
    # Sync files with correct content types
    aws s3 sync . s3://$PRIMARY_BUCKET/ \
        --delete \
        --exclude ".git/*" \
        --exclude ".DS_Store" \
        --exclude "*.md" \
        --acl public-read
    
    print_message "$GREEN" "✅ Files uploaded successfully"
    
    # Fix content types
    print_message "$YELLOW" "��� Setting correct content types..."
    
    # HTML files
    aws s3 cp s3://$PRIMARY_BUCKET/ s3://$PRIMARY_BUCKET/ \
        --recursive \
        --exclude "*" \
        --include "*.html" \
        --content-type "text/html" \
        --metadata-directive REPLACE \
        --acl public-read
    
    # CSS files
    aws s3 cp s3://$PRIMARY_BUCKET/ s3://$PRIMARY_BUCKET/ \
        --recursive \
        --exclude "*" \
        --include "*.css" \
        --content-type "text/css" \
        --metadata-directive REPLACE \
        --acl public-read
    
    # JavaScript files
    aws s3 cp s3://$PRIMARY_BUCKET/ s3://$PRIMARY_BUCKET/ \
        --recursive \
        --exclude "*" \
        --include "*.js" \
        --content-type "application/javascript" \
        --metadata-directive REPLACE \
        --acl public-read
    
    # Images
    aws s3 cp s3://$PRIMARY_BUCKET/ s3://$PRIMARY_BUCKET/ \
        --recursive \
        --exclude "*" \
        --include "*.jpg" \
        --include "*.jpeg" \
        --content-type "image/jpeg" \
        --metadata-directive REPLACE \
        --acl public-read
    
    aws s3 cp s3://$PRIMARY_BUCKET/ s3://$PRIMARY_BUCKET/ \
        --recursive \
        --exclude "*" \
        --include "*.png" \
        --content-type "image/png" \
        --metadata-directive REPLACE \
        --acl public-read
    
    print_message "$GREEN" "✅ Content types configured"
    
    cd - > /dev/null
}

# Configure static website hosting
configure_website_hosting() {
    print_message "$YELLOW" "��� Configuring static website hosting..."
    
    aws s3 website s3://$PRIMARY_BUCKET/ \
        --index-document index.html \
        --error-document error.html
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Static website hosting configured"
    else
        print_message "$RED" "❌ Failed to configure website hosting"
        exit 1
    fi
}

# Test website
test_website() {
    print_message "$YELLOW" "��� Testing website..."
    
    WEBSITE_URL="http://${PRIMARY_BUCKET}.s3-website-${PRIMARY_REGION}.amazonaws.com"
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $WEBSITE_URL)
    
    if [ "$HTTP_CODE" == "200" ]; then
        print_message "$GREEN" "✅ Website is accessible (HTTP $HTTP_CODE)"
    else
        print_message "$YELLOW" "⚠️  Website returned HTTP $HTTP_CODE"
        print_message "$YELLOW" "   This might be a permissions issue"
    fi
}

# List uploaded files
list_files() {
    print_message "$YELLOW" "��� Files in bucket:"
    aws s3 ls s3://$PRIMARY_BUCKET/ --recursive --human-readable | head -20
    
    TOTAL_FILES=$(aws s3 ls s3://$PRIMARY_BUCKET/ --recursive | wc -l)
    TOTAL_SIZE=$(aws s3 ls s3://$PRIMARY_BUCKET/ --recursive --summarize | grep "Total Size" | awk '{print $3, $4}')
    
    echo ""
    print_message "$BLUE" "��� Summary:"
    echo "   Total files: $TOTAL_FILES"
    echo "   Total size: $TOTAL_SIZE"
}

###############################################################################
# Main Script
###############################################################################

print_header "��� AWS S3 Website Deployment"

# Step 1: Load configuration
print_header "Step 1: Loading Configuration"
load_config

# Step 2: Check website files
print_header "Step 2: Checking Website Files"
check_website_files

# Step 3: Confirm deployment
print_header "Step 3: Confirm Deployment"
echo "You are about to deploy to:"
echo "   Bucket: $PRIMARY_BUCKET"
echo "   Region: $PRIMARY_REGION"
echo ""
echo -n "Continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
    print_message "$YELLOW" "⚠️  Deployment cancelled"
    exit 0
fi

# Step 4: Upload files
print_header "Step 4: Uploading Files"
upload_files

# Step 5: Configure website hosting
print_header "Step 5: Configuring Website Hosting"
configure_website_hosting

# Step 6: Test website
print_header "Step 6: Testing Website"
test_website

# Step 7: List files
print_header "Step 7: Deployment Summary"
list_files

# Final summary
print_header "✅ Deployment Complete!"
print_message "$GREEN" "Your website is now live!"
echo ""
print_message "$BLUE" "��� Website URL:"
echo "   $WEBSITE_URL"
echo ""
print_message "$YELLOW" "Next steps:"
echo "   1. Visit your website in a browser"
echo "   2. Run ../security/apply-bucket-policy.sh (if not done)"
echo "   3. Run ../security/enable-encryption.sh"
echo "   4. Run ../replication/setup-replication.sh for DR"
echo ""
print_message "$BLUE" "��� Tip: Bookmark your website URL!"

exit 0
