#!/bin/bash

###############################################################################
# S3 Cross-Region Replication Setup Script
# 
# Description: Sets up CRR between primary and DR buckets
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
    
    # Get AWS Account ID
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    
    print_message "$GREEN" "✅ Configuration loaded"
    echo "   Account ID: $ACCOUNT_ID"
    echo "   Source: $PRIMARY_BUCKET ($PRIMARY_REGION)"
    echo "   Destination: $DR_BUCKET ($DR_REGION)"
}

# Check versioning
check_versioning() {
    print_message "$YELLOW" "��� Checking versioning status..."
    
    # Check primary bucket
    PRIMARY_VERSIONING=$(aws s3api get-bucket-versioning \
        --bucket $PRIMARY_BUCKET \
        --query 'Status' \
        --output text)
    
    # Check DR bucket
    DR_VERSIONING=$(aws s3api get-bucket-versioning \
        --bucket $DR_BUCKET \
        --query 'Status' \
        --output text)
    
    if [ "$PRIMARY_VERSIONING" == "Enabled" ] && [ "$DR_VERSIONING" == "Enabled" ]; then
        print_message "$GREEN" "✅ Versioning is enabled on both buckets"
    else
        print_message "$RED" "❌ Versioning must be enabled on both buckets"
        
        if [ "$PRIMARY_VERSIONING" != "Enabled" ]; then
            print_message "$YELLOW" "   Enabling versioning on primary bucket..."
            aws s3api put-bucket-versioning \
                --bucket $PRIMARY_BUCKET \
                --versioning-configuration Status=Enabled
        fi
        
        if [ "$DR_VERSIONING" != "Enabled" ]; then
            print_message "$YELLOW" "   Enabling versioning on DR bucket..."
            aws s3api put-bucket-versioning \
                --bucket $DR_BUCKET \
                --versioning-configuration Status=Enabled
        fi
        
        print_message "$GREEN" "✅ Versioning enabled on both buckets"
    fi
}

# Create IAM role
create_iam_role() {
    ROLE_NAME="s3-replication-role-$(date +%s)"
    
    print_message "$YELLOW" "��� Creating IAM role: $ROLE_NAME..."
    
    # Create trust policy
    TRUST_POLICY=$(cat ../../policies/iam-role-trust.json)
    
    # Create role
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document "$TRUST_POLICY" \
        > /dev/null
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ IAM role created: $ROLE_NAME"
    else
        print_message "$RED" "❌ Failed to create IAM role"
        exit 1
    fi
    
    # Attach permissions policy
    print_message "$YELLOW" "��� Attaching permissions policy..."
    
    # Read and customize policy
    POLICY_TEMPLATE=$(cat ../../policies/iam-replication-policy.json)
    POLICY_DOCUMENT=$(echo "$POLICY_TEMPLATE" | \
        sed "s/SOURCE_BUCKET_NAME/$PRIMARY_BUCKET/g" | \
        sed "s/DESTINATION_BUCKET_NAME/$DR_BUCKET/g")
    
    aws iam put-role-policy \
        --role-name $ROLE_NAME \
        --policy-name S3ReplicationPolicy \
        --policy-document "$POLICY_DOCUMENT"
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Permissions policy attached"
    else
        print_message "$RED" "❌ Failed to attach policy"
        exit 1
    fi
    
    # Get role ARN
    ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
    print_message "$GREEN" "✅ Role ARN: $ROLE_ARN"
    
    # Save role name to config
    echo "" >> $CONFIG_FILE
    echo "# Replication Configuration" >> $CONFIG_FILE
    echo "REPLICATION_ROLE_NAME=$ROLE_NAME" >> $CONFIG_FILE
    echo "REPLICATION_ROLE_ARN=$ROLE_ARN" >> $CONFIG_FILE
}

# Wait for IAM propagation
wait_for_iam() {
    print_message "$YELLOW" "⏳ Waiting for IAM role propagation (10 seconds)..."
    sleep 10
    print_message "$GREEN" "✅ IAM role should be ready"
}

# Configure replication
configure_replication() {
    print_message "$YELLOW" "��� Configuring replication rule..."
    
    # Read and customize replication policy
    REPLICATION_TEMPLATE=$(cat ../../policies/replication-policy.json)
    REPLICATION_CONFIG=$(echo "$REPLICATION_TEMPLATE" | \
        sed "s/ACCOUNT_ID/$ACCOUNT_ID/g" | \
        sed "s/REPLICATION_ROLE_NAME/$ROLE_NAME/g" | \
        sed "s/DESTINATION_BUCKET_NAME/$DR_BUCKET/g")
    
    # Save to temp file
    TEMP_CONFIG="/tmp/replication-config.json"
    echo "$REPLICATION_CONFIG" > $TEMP_CONFIG
    
    # Apply replication configuration
    aws s3api put-bucket-replication \
        --bucket $PRIMARY_BUCKET \
        --replication-configuration file://$TEMP_CONFIG
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Replication configured successfully"
    else
        print_message "$RED" "❌ Failed to configure replication"
        print_message "$YELLOW" "   This might be due to IAM propagation delay"
        print_message "$YELLOW" "   Try running this script again in 1-2 minutes"
        rm -f $TEMP_CONFIG
        exit 1
    fi
    
    # Cleanup
    rm -f $TEMP_CONFIG
}

# Verify replication
verify_replication() {
    print_message "$YELLOW" "��� Verifying replication configuration..."
    
    aws s3api get-bucket-replication \
        --bucket $PRIMARY_BUCKET \
        --output json | jq '.'
    
    if [ $? -eq 0 ]; then
        print_message "$GREEN" "✅ Replication configuration verified"
    else
        print_message "$YELLOW" "⚠️  Could not verify replication"
    fi
}

# Test replication
test_replication() {
    print_message "$YELLOW" "�� Testing replication..."
    
    # Create test file
    TEST_FILE="/tmp/replication-test-$(date +%s).txt"
    echo "Replication test - $(date)" > $TEST_FILE
    
    # Upload to primary bucket
    print_message "$YELLOW" "   Uploading test file to primary bucket..."
    aws s3 cp $TEST_FILE s3://$PRIMARY_BUCKET/replication-test.txt
    
    # Wait for replication
    print_message "$YELLOW" "   Waiting 60 seconds for replication..."
    sleep 60
    
    # Check if file exists in DR bucket
    if aws s3 ls s3://$DR_BUCKET/replication-test.txt > /dev/null 2>&1; then
        print_message "$GREEN" "✅ Replication successful! File found in DR bucket"
        
        # Get replication status
        REPLICATION_STATUS=$(aws s3api head-object \
            --bucket $PRIMARY_BUCKET \
            --key replication-test.txt \
            --query 'ReplicationStatus' \
            --output text 2>/dev/null)
        
        print_message "$BLUE" "   Replication status: $REPLICATION_STATUS"
    else
        print_message "$YELLOW" "⚠️  File not yet replicated (may take up to 15 minutes)"
        print_message "$BLUE" "   Check again later with: aws s3 ls s3://$DR_BUCKET/"
    fi
    
    # Cleanup
    rm -f $TEST_FILE
}

###############################################################################
# Main Script
###############################################################################

print_header "��� AWS S3 Cross-Region Replication Setup"

# Step 1: Load configuration
print_header "Step 1: Loading Configuration"
load_config

# Step 2: Confirm setup
print_header "Step 2: Confirm Setup"
echo "This will configure replication from:"
echo "   Source: $PRIMARY_BUCKET ($PRIMARY_REGION)"
echo "   Destination: $DR_BUCKET ($DR_REGION)"
echo ""
print_message "$YELLOW" "⚠️  Note: Replication incurs additional costs"
echo ""
echo -n "Continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
    print_message "$YELLOW" "⚠️  Operation cancelled"
    exit 0
fi

# Step 3: Check versioning
print_header "Step 3: Checking Versioning"
check_versioning

# Step 4: Create IAM role
print_header "Step 4: Creating IAM Role"
create_iam_role

# Step 5: Wait for IAM propagation
print_header "Step 5: IAM Propagation"
wait_for_iam

# Step 6: Configure replication
print_header "Step 6: Configuring Replication"
configure_replication

# Step 7: Verify configuration
print_header "Step 7: Verifying Configuration"
verify_replication

# Step 8: Test replication
print_header "Step 8: Testing Replication"
test_replication

# Final summary
print_header "✅ Replication Setup Complete!"
print_message "$GREEN" "Cross-region replication is now active!"
echo ""
print_message "$BLUE" "Replication details:"
echo "   Source: $PRIMARY_BUCKET ($PRIMARY_REGION)"
echo "   Destination: $DR_BUCKET ($DR_REGION)"
echo "   IAM Role: $ROLE_NAME"
echo "   Replication Time: < 15 minutes"
echo "   Delete Markers: Replicated"
echo ""
print_message "$BLUE" "What happens now:"
echo "   ✅ All new objects will be replicated automatically"
echo "   ✅ Existing objects are NOT replicated (use S3 Batch)"
echo "   ✅ Deletions are replicated (if delete markers enabled)"
echo "   ✅ Encrypted objects are replicated"
echo ""
print_message "$YELLOW" "Monitoring:"
echo "   • Check replication status in S3 console"
echo "   • Use CloudWatch metrics for monitoring"
echo "   • Run ../monitoring/check-replication.sh for status"

exit 0
