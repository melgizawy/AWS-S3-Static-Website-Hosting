#!/bin/bash

###############################################################################
# Apply Bucket Policy Script
# 
# Description: Applies public read bucket policy to S3 bucket
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
        exit 1
    fi
    
    source $CONFIG_FILE
    print_message "$GREEN" "✅ Configuration loaded"
}

# Disable Block Public Access
disable_block_public_access() {
    print_message "$YELLOW" "��� Disabling Block Public Access..."
    
    aws s3api put-public-access-block \
        --bucket $PRIMARY_BUCKET \
        --public-access-block-configuration \
        "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Block Public Access disabled"
    else
        print_message "$RED" "❌ Failed to disable Block Public Access"
        exit 1
    fi
}

# Apply bucket policy
apply_policy() {
    print_message "$YELLOW" "��� Applying bucket policy..."
    
    POLICY_FILE="../../policies/bucket-policy.json"
    
    if [ ! -f "$POLICY_FILE" ]; then
        print_message "$RED" "❌ Error: bucket-policy.json not found"
        exit 1
    fi
    
    # Create temporary policy file with bucket name replaced
    TEMP_POLICY="/tmp/bucket-policy-temp.json"
    sed "s/YOUR_BUCKET_NAME/$PRIMARY_BUCKET/g" $POLICY_FILE > $TEMP_POLICY
    
    # Apply policy
    aws s3api put-bucket-policy \
        --bucket $PRIMARY_BUCKET \
        --policy file://$TEMP_POLICY
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Bucket policy applied successfully"
    else
        print_message "$RED" "❌ Failed to apply bucket policy"
        rm -f $TEMP_POLICY
        exit 1
    fi
    
    # Cleanup
    rm -f $TEMP_POLICY
}

# Verify policy
verify_policy() {
    print_message "$YELLOW" "��� Verifying bucket policy..."
    
    aws s3api get-bucket-policy \
        --bucket $PRIMARY_BUCKET \
        --query Policy \
        --output text | jq '.'
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Policy verified"
    else
        print_message "$YELLOW" "⚠️  Could not verify policy"
    fi
}

# Test public access
test_access() {
    print_message "$YELLOW" "��� Testing public access..."
    
    WEBSITE_URL="http://${PRIMARY_BUCKET}.s3-website-${PRIMARY_REGION}.amazonaws.com"
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $WEBSITE_URL)
    
    if [ "$HTTP_CODE" == "200" ]; then
        print_message "$GREEN" "✅ Website is publicly accessible (HTTP $HTTP_CODE)"
    elif [ "$HTTP_CODE" == "403" ]; then
        print_message "$RED" "❌ Access Denied (HTTP 403)"
        print_message "$YELLOW" "   Check your bucket policy configuration"
    else
        print_message "$YELLOW" "⚠️  Unexpected response (HTTP $HTTP_CODE)"
    fi
}

###############################################################################
# Main Script
###############################################################################

print_header "�� AWS S3 Bucket Policy Configuration"

# Step 1: Load configuration
print_header "Step 1: Loading Configuration"
load_config

# Step 2: Confirm action
print_header "Step 2: Confirm Action"
print_message "$YELLOW" "⚠️  Warning: This will make your bucket publicly readable!"
echo ""
echo "Bucket: $PRIMARY_BUCKET"
echo ""
echo -n "Continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
    print_message "$YELLOW" "⚠️  Operation cancelled"
    exit 0
fi

# Step 3: Disable Block Public Access
print_header "Step 3: Configuring Public Access"
disable_block_public_access

# Step 4: Apply policy
print_header "Step 4: Applying Bucket Policy"
apply_policy

# Step 5: Verify policy
print_header "Step 5: Verifying Policy"
verify_policy

# Step 6: Test access
print_header "Step 6: Testing Public Access"
test_access

# Final summary
print_header "✅ Policy Configuration Complete!"
print_message "$GREEN" "Your bucket is now configured for public read access"
echo ""
print_message "$BLUE" "Security notes:"
echo "   ✅ Objects are publicly readable"
echo "   ✅ HTTPS enforcement enabled (if configured)"
echo "   ✅ Bucket policy applied successfully"
echo ""
print_message "$YELLOW" "Next steps:"
echo "   1. Run ../security/enable-encryption.sh"
echo "   2. Run ../replication/setup-replication.sh"

exit 0
