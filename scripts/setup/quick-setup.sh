#!/bin/bash

###############################################################################
# AWS S3 Portfolio - Quick Setup Script
#

#
# Description: Complete automated setup for S3 static website hosting
# This script runs all necessary steps in sequence
# Author: Mohammad Elgizawy
# Date: 2025
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

print_message() {
    echo -e "${1}${2}${NC}"
}

print_header() {
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    print_message "$CYAN" "  $1"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
}

print_banner() {
    clear
    print_message "$MAGENTA" "
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║         AWS S3 Portfolio - Quick Setup Wizard            ║
    ║                                                           ║
    ║         Automated deployment in 5 easy steps             ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
    "
}

check_prerequisites() {
    print_header "🔍 Checking Prerequisites"

    local all_good=true

    # Check AWS CLI
    if command -v aws &> /dev/null; then
        AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1)
        print_message "$GREEN" "✅ AWS CLI is installed ($AWS_VERSION)"
    else
        print_message "$RED" "❌ AWS CLI is NOT installed"
        echo "   Please install: https://aws.amazon.com/cli/"
        all_good=false
    fi
    # Check AWS credentials
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
        print_message "$GREEN" "✅ AWS credentials configured"
        print_message "$BLUE" "   Account: $ACCOUNT_ID"
        print_message "$BLUE" "   User: $USER_ARN"
    else
        print_message "$RED" "❌ AWS credentials NOT configured"
        echo "   Please run: aws configure"
        all_good=false
    fi
    # Check jq (optional but recommended)
    if command -v jq &> /dev/null; then
        print_message "$GREEN" "✅ jq is installed (for JSON parsing)"
    else
        print_message "$YELLOW" "⚠️  jq is not installed (recommended but not required)"
    fi
    # Check website files
    if [ -f "$PROJECT_ROOT/website-files/index.html" ]; then
        print_message "$GREEN" "✅ Website files found"
    else
        print_message "$RED" "❌ Website files NOT found"
        echo "   Please ensure website-files/index.html exists"
        all_good=false
    fi
    if [ "$all_good" = false ]; then
        echo ""
        print_message "$RED" "❌ Prerequisites check failed"
        echo "   Please fix the issues above and run again"
        exit 1
    fi
    echo ""
    print_message "$GREEN" "✅ All prerequisites met!"
}

get_configuration() {
    print_header "⚙️  Configuration"

    echo "Let's set up your project configuration..."
    echo ""

    # Get base name
    while true; do
        echo -n "Enter a base name for your project (e.g., mywebsite): "
        read BASE_NAME
        if [ -z "$BASE_NAME" ]; then
            print_message "$RED" "❌ Name cannot be empty"
            continue
        fi
        # Convert to lowercase and remove spaces
        BASE_NAME=$(echo "$BASE_NAME" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        break
    done
    # Get primary region
    echo ""
    echo "Available regions:"
    echo "  1. us-east-1 (N. Virginia)"
    echo "  2. us-west-2 (Oregon)"
    echo "  3. eu-west-1 (Ireland)"
    echo "  4. ap-southeast-1 (Singapore)"
    echo ""
    echo -n "Select primary region (1-4) [default: 1]: "
    read REGION_CHOICE
    case ${REGION_CHOICE:-1} in
        1) PRIMARY_REGION="us-east-1" ;;
        2) PRIMARY_REGION="us-west-2" ;;
        3) PRIMARY_REGION="eu-west-1" ;;
        4) PRIMARY_REGION="ap-southeast-1" ;;
        *) PRIMARY_REGION="us-east-1" ;;
    esac
    # Get DR region
    echo ""
    echo "Select disaster recovery region (should be different from primary):"
    echo "  1. eu-west-1 (Ireland)"
    echo "  2. us-west-2 (Oregon)"
    echo "  3. ap-southeast-1 (Singapore)"
    echo ""
    echo -n "Select DR region (1-3) [default: 1]: "
    read DR_REGION_CHOICE
    case ${DR_REGION_CHOICE:-1} in
        1) DR_REGION="eu-west-1" ;;
        2) DR_REGION="us-west-2" ;;
        3) DR_REGION="ap-southeast-1" ;;
        *) DR_REGION="eu-west-1" ;;
    esac
    # Generate bucket names
    TIMESTAMP=$(date +%s)
    PRIMARY_BUCKET="${BASE_NAME}-website-${TIMESTAMP}"
    DR_BUCKET="${BASE_NAME}-dr-${TIMESTAMP}"
    LOGS_BUCKET="${BASE_NAME}-logs-${TIMESTAMP}"

    # Summary
    echo ""
    print_header "📋 Configuration Summary"
    print_message "$BLUE" "Project Name: $BASE_NAME"
    print_message "$BLUE" "Primary Bucket: $PRIMARY_BUCKET"
    print_message "$BLUE" "Primary Region: $PRIMARY_REGION"
    print_message "$BLUE" "DR Bucket: $DR_BUCKET"
    print_message "$BLUE" "DR Region: $DR_REGION"
    print_message "$BLUE" "Logs Bucket: $LOGS_BUCKET"
    echo ""

    echo -n "Proceed with this configuration? (yes/no): "
    read CONFIRM

    if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
        print_message "$YELLOW" "⚠️  Setup cancelled"
        exit 0
    fi
}

create_buckets() {
    print_header "📦 Step 1/5: Creating S3 Buckets"

    # Create primary bucket
    print_message "$YELLOW" "Creating primary bucket: $PRIMARY_BUCKET..."
    if [ "$PRIMARY_REGION" == "us-east-1" ]; then
        aws s3 mb s3://$PRIMARY_BUCKET --region $PRIMARY_REGION
    else
        aws s3api create-bucket \
            --bucket $PRIMARY_BUCKET \
            --region $PRIMARY_REGION \
            --create-bucket-configuration LocationConstraint=$PRIMARY_REGION
    fi
    print_message "$GREEN" "✅ Primary bucket created"
    # Create DR bucket
    print_message "$YELLOW" "Creating DR bucket: $DR_BUCKET..."
    if [ "$DR_REGION" == "us-east-1" ]; then
        aws s3 mb s3://$DR_BUCKET --region $DR_REGION
    else
        aws s3api create-bucket \
            --bucket $DR_BUCKET \
            --region $DR_REGION \
            --create-bucket-configuration LocationConstraint=$DR_REGION
    fi
    print_message "$GREEN" "✅ DR bucket created"
    # Create logs bucket
    print_message "$YELLOW" "Creating logs bucket: $LOGS_BUCKET..."
    if [ "$PRIMARY_REGION" == "us-east-1" ]; then
        aws s3 mb s3://$LOGS_BUCKET --region $PRIMARY_REGION
    else
        aws s3api create-bucket \
            --bucket $LOGS_BUCKET \
            --region $PRIMARY_REGION \
            --create-bucket-configuration LocationConstraint=$PRIMARY_REGION
    fi
    print_message "$GREEN" "✅ Logs bucket created"
    # Enable versioning
    print_message "$YELLOW" "Enabling versioning..."
    aws s3api put-bucket-versioning --bucket $PRIMARY_BUCKET --versioning-configuration Status=Enabled
    aws s3api put-bucket-versioning --bucket $DR_BUCKET --versioning-configuration Status=Enabled
    print_message "$GREEN" "✅ Versioning enabled"
    # Save configuration
    cat > "$PROJECT_ROOT/bucket-config.txt" << EOF
# AWS S3 Bucket Configuration
# Generated: $(date)

PRIMARY_BUCKET=$PRIMARY_BUCKET
PRIMARY_REGION=$PRIMARY_REGION

DR_BUCKET=$DR_BUCKET
DR_REGION=$DR_REGION

LOGS_BUCKET=$LOGS_BUCKET
LOGS_REGION=$PRIMARY_REGION

WEBSITE_URL=http://${PRIMARY_BUCKET}.s3-website-${PRIMARY_REGION}.amazonaws.com
EOF

    print_message "$GREEN" "✅ Configuration saved to bucket-config.txt"
}

deploy_website() {
    print_header "🚀 Step 2/5: Deploying Website"

    cd "$PROJECT_ROOT/website-files"

    print_message "$YELLOW" "Uploading files to S3..."
    # Bucket has "Bucket owner enforced" — ACLs are not supported.
    # Let the CLI set Content-Type automatically and do not pass --acl.
    aws s3 sync . s3://$PRIMARY_BUCKET/ \
        --exclude ".git/*" \
        --exclude ".DS_Store" \
        --only-show-errors

    # Configure static website hosting so index.html / error.html are served
    print_message "$YELLOW" "Configuring S3 static website hosting..."
    aws s3 website s3://$PRIMARY_BUCKET --index-document index.html --error-document error.html

    cd - > /dev/null

    print_message "$GREEN" "✅ Website deployed successfully"
}


configure_security() {
    print_header "🔐 Step 3/5: Configuring Security"

    # Disable block public access
    print_message "$YELLOW" "Configuring public access..."
    aws s3api put-public-access-block \
        --bucket $PRIMARY_BUCKET \
        --public-access-block-configuration \
        "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

    # Apply bucket policy
    print_message "$YELLOW" "Applying bucket policy..."
    # Build policy into a variable instead of writing to /tmp (more portable on Windows/Git-Bash)
    POLICY_JSON=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${PRIMARY_BUCKET}/*"
    }
  ]
}
EOF
)

    aws s3api put-bucket-policy \
        --bucket "$PRIMARY_BUCKET" \
        --policy "$POLICY_JSON"

    # Enable encryption
    print_message "$YELLOW" "Enabling encryption..."
    aws s3api put-bucket-encryption \
        --bucket $PRIMARY_BUCKET \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }]
        }'
    print_message "$GREEN" "✅ Security configured"
}

setup_replication() {
    print_header "🔄 Step 4/5: Setting Up Replication"

    ROLE_NAME="s3-replication-role-${TIMESTAMP}"

    # Create IAM role
    print_message "$YELLOW" "Creating IAM role..."
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {"Service": "s3.amazonaws.com"},
                "Action": "sts:AssumeRole"
            }]
        }' > /dev/null

    # Attach policy
    print_message "$YELLOW" "Attaching replication policy..."
    aws iam put-role-policy \
        --role-name $ROLE_NAME \
        --policy-name S3ReplicationPolicy \
        --policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:GetReplicationConfiguration",
                        "s3:ListBucket"
                    ],
                    "Resource": "arn:aws:s3:::'$PRIMARY_BUCKET'"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:GetObjectVersionForReplication",
                        "s3:GetObjectVersionAcl",
                        "s3:GetObjectVersionTagging"
                    ],
                    "Resource": "arn:aws:s3:::'$PRIMARY_BUCKET'/*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:ReplicateObject",
                        "s3:ReplicateDelete",
                        "s3:ReplicateTags"
                    ],
                    "Resource": "arn:aws:s3:::'$DR_BUCKET'/*"
                }
            ]
        }'

    # Wait for IAM propagation
    print_message "$YELLOW" "Waiting for IAM propagation..."
    sleep 10

    # Configure replication
    print_message "$YELLOW" "Configuring replication..."
    ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

    aws s3api put-bucket-replication \
        --bucket $PRIMARY_BUCKET \
        --replication-configuration '{
            "Role": "'$ROLE_ARN'",
            "Rules": [{
                "Status": "Enabled",
                "Priority": 1,
                "DeleteMarkerReplication": {"Status": "Enabled"},
                "Filter": {},
                "Destination": {
                    "Bucket": "arn:aws:s3:::'$DR_BUCKET'",
                    "ReplicationTime": {
                        "Status": "Enabled",
                        "Time": {"Minutes": 15}
                    },
                    "Metrics": {
                        "Status": "Enabled",
                        "EventThreshold": {"Minutes": 15}
                    }
                }
            }]
        }'

    print_message "$GREEN" "✅ Replication configured"
}

test_deployment() {
    print_header "🧪 Step 5/5: Testing Deployment"

    WEBSITE_URL="http://${PRIMARY_BUCKET}.s3-website-${PRIMARY_REGION}.amazonaws.com"

    print_message "$YELLOW" "Testing website access..."
    sleep 5

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $WEBSITE_URL)

    if [ "$HTTP_CODE" == "200" ]; then
        print_message "$GREEN" "✅ Website is accessible (HTTP $HTTP_CODE)"
    else
        print_message "$YELLOW" "⚠️  Website returned HTTP $HTTP_CODE"
    fi

    print_message "$GREEN" "✅ Deployment test complete"
}

show_summary() {
    print_header "🎉 Setup Complete!"

    WEBSITE_URL="http://${PRIMARY_BUCKET}.s3-website-${PRIMARY_REGION}.amazonaws.com"

    print_message "$GREEN" "Your AWS S3 portfolio is now live!"
    echo ""
    print_message "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_message "$BLUE" "🌐 Website URL:"
    print_message "$YELLOW" "   $WEBSITE_URL"
    echo ""
    print_message "$BLUE" "📦 Buckets Created:"
    echo "   • Primary: $PRIMARY_BUCKET ($PRIMARY_REGION)"
    echo "   • DR: $DR_BUCKET ($DR_REGION)"
    echo "   • Logs: $LOGS_BUCKET ($PRIMARY_REGION)"
    echo ""
    print_message "$BLUE" "✅ Features Enabled:"
    echo "   • Static website hosting"
    echo "   • AES-256 encryption"
    echo "   • Versioning"
    echo "   • Cross-region replication"
    echo "   • Public read access"
    print_message "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_message "$MAGENTA" "📝 Next Steps:"
    echo "   1. Visit your website in a browser"
    echo "   2. Check bucket-config.txt for details"
    echo "   3. Customize website content in website-files/"
    echo "   4. Run ./deployment/update-website.sh to update"
    echo ""
    print_message "$YELLOW" "💡 Tip: Bookmark your website URL!"
    echo ""
}

###############################################################################
# Main Script
###############################################################################

print_banner
sleep 2

check_prerequisites
sleep 1

get_configuration
sleep 1

create_buckets
sleep 2

deploy_website
sleep 2

configure_security
sleep 2

setup_replication
sleep 2

test_deployment
sleep 1

show_summary

exit 0
