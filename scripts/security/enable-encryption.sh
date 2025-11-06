#!/bin/bash

###############################################################################
# Enable S3 Bucket Encryption Script
# 
# Description: Enables server-side encryption for S3 buckets
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

# Enable encryption on a bucket
enable_bucket_encryption() {
    local bucket_name=$1
    local bucket_description=$2
    
    print_message "$YELLOW" "��� Enabling encryption on $bucket_description..."
    
    aws s3api put-bucket-encryption \
        --bucket $bucket_name \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }]
        }'
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Encryption enabled on $bucket_name"
    else
        print_message "$RED" "❌ Failed to enable encryption on $bucket_name"
        return 1
    fi
}

# Verify encryption
verify_encryption() {
    local bucket_name=$1
    
    print_message "$YELLOW" "��� Verifying encryption on $bucket_name..."
    
    ENCRYPTION_STATUS=$(aws s3api get-bucket-encryption \
        --bucket $bucket_name \
        --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' \
        --output text 2>/dev/null)
    
    if [ "$ENCRYPTION_STATUS" == "AES256" ]; then
        print_message "$GREEN" "✅ Encryption verified: AES256"
    else
        print_message "$YELLOW" "⚠️  Could not verify encryption"
    fi
}

# Test encryption on uploaded object
test_encryption() {
    print_message "$YELLOW" "��� Testing encryption on new object..."
    
    # Create test file
    TEST_FILE="/tmp/encryption-test-$(date +%s).txt"
    echo "This is a test file to verify encryption" > $TEST_FILE
    
    # Upload test file
    aws s3 cp $TEST_FILE s3://$PRIMARY_BUCKET/test-encryption.txt
    
    # Check encryption status
    OBJECT_ENCRYPTION=$(aws s3api head-object \
        --bucket $PRIMARY_BUCKET \
        --key test-encryption.txt \
        --query 'ServerSideEncryption' \
        --output text 2>/dev/null)
    
    if [ "$OBJECT_ENCRYPTION" == "AES256" ]; then
        print_message "$GREEN" "✅ Test successful: Object is encrypted with AES256"
    else
        print_message "$YELLOW" "⚠️  Encryption test returned: $OBJECT_ENCRYPTION"
    fi
    
    # Cleanup
    aws s3 rm s3://$PRIMARY_BUCKET/test-encryption.txt
    rm -f $TEST_FILE
}

###############################################################################
# Main Script
###############################################################################

print_header "��� AWS S3 Bucket Encryption Setup"

# Step 1: Load configuration
print_header "Step 1: Loading Configuration"
load_config

# Step 2: Confirm action
print_header "Step 2: Confirm Action"
echo "This will enable AES-256 encryption on:"
echo "   • Primary bucket: $PRIMARY_BUCKET"
echo "   • DR bucket: $DR_BUCKET"
echo "   • Logs bucket: $LOGS_BUCKET"
echo ""
echo -n "Continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
    print_message "$YELLOW" "⚠️  Operation cancelled"
    exit 0
fi

# Step 3: Enable encryption on primary bucket
print_header "Step 3: Encrypting Primary Bucket"
enable_bucket_encryption $PRIMARY_BUCKET "Primary Bucket"
verify_encryption $PRIMARY_BUCKET

# Step 4: Enable encryption on DR bucket
print_header "Step 4: Encrypting DR Bucket"
enable_bucket_encryption $DR_BUCKET "DR Bucket"
verify_encryption $DR_BUCKET

# Step 5: Enable encryption on logs bucket
print_header "Step 5: Encrypting Logs Bucket"
enable_bucket_encryption $LOGS_BUCKET "Logs Bucket"
verify_encryption $LOGS_BUCKET

# Step 6: Test encryption
print_header "Step 6: Testing Encryption"
test_encryption

# Final summary
print_header "✅ Encryption Setup Complete!"
print_message "$GREEN" "All buckets are now encrypted!"
echo ""
print_message "$BLUE" "Encryption details:"
echo "   Algorithm: AES-256 (SSE-S3)"
echo "   Bucket Key: Enabled (reduces costs)"
echo "   Applied to: All new objects automatically"
echo ""
print_message "$BLUE" "Security benefits:"
echo "   ✅ Data encrypted at rest"
echo "   ✅ AWS-managed encryption keys"
echo "   ✅ No performance impact"
echo "   ✅ Transparent encryption/decryption"
echo ""
print_message "$YELLOW" "Next steps:"
echo "   1. All future uploads will be encrypted automatically"
echo "   2. Existing objects remain as-is (re-upload to encrypt)"
echo "   3. Consider using AWS KMS for more control (optional)"

exit 0
