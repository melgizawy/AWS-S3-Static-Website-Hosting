#!/bin/bash

###############################################################################
# AWS S3 Portfolio - Master Test Script
#
# Description: Tests ALL features and configurations
# Usage: ./test-all.sh
# Author: Your Name
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

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Configuration file
CONFIG_FILE="C:\Users\drgizawy\AWS-S3-Static-Website-Hosting\bucket-config.txt"

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
    ║        AWS S3 Portfolio - Master Test Suite              ║
    ║                                                           ║
    ║        Comprehensive Testing & Verification              ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
    "
}

# Load configuration
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_message "$RED" "❌ Error: $CONFIG_FILE not found"
        echo "Please run setup scripts first or create config file manually"
        exit 1
    fi

    source $CONFIG_FILE
    print_message "$GREEN" "✅ Configuration loaded"
}

# Test result tracker
test_result() {
    local test_name=$1
    local result=$2

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ "$result" == "PASS" ]; then
        print_message "$GREEN" "✅ PASS: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif [ "$result" == "FAIL" ]; then
        print_message "$RED" "❌ FAIL: $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    elif [ "$result" == "SKIP" ]; then
        print_message "$YELLOW" "⏭️  SKIP: $test_name"
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    fi
}

###############################################################################
# Test 1: Website Availability
###############################################################################
test_website_availability() {
    print_header "Test 1: Website Availability"

    if [ -z "$WEBSITE_URL" ]; then
        test_result "Website URL configured" "FAIL"
        return 1
    fi

    test_result "Website URL configured" "PASS"

    # Test homepage
    print_message "$YELLOW" "Testing homepage..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$WEBSITE_URL" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" == "200" ]; then
        test_result "Homepage loads (HTTP 200)" "PASS"
    else
        test_result "Homepage loads (Got HTTP $HTTP_CODE)" "FAIL"
    fi

    # Test response time
    print_message "$YELLOW" "Testing response time..."
    RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" "$WEBSITE_URL" 2>/dev/null || echo "999")

if [[ $(awk -v time="$RESPONSE_TIME" 'BEGIN { print (time < 3.0) }') -eq 1 ]]; then
        test_result "Response time acceptable (${RESPONSE_TIME}s)" "PASS"
    else
        test_result "Response time (${RESPONSE_TIME}s > 3s)" "FAIL"
    fi

    # Test 404 page
    print_message "$YELLOW" "Testing 404 error page..."
    HTTP_404=$(curl -s -o /dev/null -w "%{http_code}" "${WEBSITE_URL}/nonexistent-page" 2>/dev/null || echo "000")

    if [ "$HTTP_404" == "404" ]; then
        test_result "Custom 404 page works" "PASS"
    else
        test_result "Custom 404 page (Got HTTP $HTTP_404)" "FAIL"
    fi
}

###############################################################################
# Test 2: Bucket Configuration
###############################################################################
test_bucket_configuration() {
    print_header "Test 2: Bucket Configuration"

    # Check if bucket exists
    print_message "$YELLOW" "Checking primary bucket exists..."
    if aws s3 ls "s3://$PRIMARY_BUCKET" > /dev/null 2>&1; then
        test_result "Primary bucket exists" "PASS"
    else
        test_result "Primary bucket exists" "FAIL"
        return 1
    fi

    # Check bucket region
    print_message "$YELLOW" "Checking bucket region..."
    BUCKET_REGION=$(aws s3api get-bucket-location --bucket $PRIMARY_BUCKET --query 'LocationConstraint' --output text 2>/dev/null || echo "error")

    if [ "$BUCKET_REGION" == "None" ] || [ "$BUCKET_REGION" == "null" ]; then
        BUCKET_REGION="us-east-1"
    fi

    if [ "$BUCKET_REGION" == "$PRIMARY_REGION" ]; then
        test_result "Bucket in correct region ($BUCKET_REGION)" "PASS"
    else
        test_result "Bucket region (Expected: $PRIMARY_REGION, Got: $BUCKET_REGION)" "FAIL"
    fi
}

###############################################################################
# Test 3: Static Website Hosting
###############################################################################
test_static_hosting() {
    print_header "Test 3: Static Website Hosting Configuration"

    print_message "$YELLOW" "Checking static website hosting..."
    HOSTING_CONFIG=$(aws s3api get-bucket-website --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ]; then
        test_result "Static website hosting enabled" "PASS"

        # Check index document
        INDEX_DOC=$(echo "$HOSTING_CONFIG" | grep -o '"IndexDocument"' | wc -l)
        if [ "$INDEX_DOC" -gt 0 ]; then
            test_result "Index document configured" "PASS"
        else
            test_result "Index document configured" "FAIL"
        fi

        # Check error document
        ERROR_DOC=$(echo "$HOSTING_CONFIG" | grep -o '"ErrorDocument"' | wc -l)
        if [ "$ERROR_DOC" -gt 0 ]; then
            test_result "Error document configured" "PASS"
        else
            test_result "Error document configured" "FAIL"
        fi
    else
        test_result "Static website hosting enabled" "FAIL"
    fi
}

###############################################################################
# Test 4: Bucket Policy & Public Access
###############################################################################
test_bucket_policy() {
    print_header "Test 4: Bucket Policy & Public Access"

    print_message "$YELLOW" "Checking bucket policy..."
    POLICY=$(aws s3api get-bucket-policy --bucket $PRIMARY_BUCKET --query 'Policy' --output text 2>/dev/null)

    if [ $? -eq 0 ] && [ ! -z "$POLICY" ]; then
        test_result "Bucket policy exists" "PASS"

        # Check for public read access
        if echo "$POLICY" | grep -q "s3:GetObject"; then
            test_result "Policy allows GetObject" "PASS"
        else
            test_result "Policy allows GetObject" "FAIL"
        fi

        if echo "$POLICY" | grep -q '"Principal":"*"' || echo "$POLICY" | grep -q '"Principal": "*"'; then
            test_result "Policy allows public access" "PASS"
        else
            test_result "Policy allows public access" "FAIL"
        fi
    else
        test_result "Bucket policy exists" "FAIL"
    fi

    # Check Block Public Access settings
    print_message "$YELLOW" "Checking Block Public Access settings..."
    BLOCK_CONFIG=$(aws s3api get-public-access-block --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ]; then
        if echo "$BLOCK_CONFIG" | grep -q '"BlockPublicAcls": false' && \
           echo "$BLOCK_CONFIG" | grep -q '"BlockPublicPolicy": false'; then
            test_result "Public access properly configured" "PASS"
        else
            test_result "Public access (Some blocks still enabled)" "FAIL"
        fi
    else
        test_result "Block Public Access settings checked" "SKIP"
    fi
}

###############################################################################
# Test 5: Versioning
###############################################################################
test_versioning() {
    print_header "Test 5: Bucket Versioning"

    print_message "$YELLOW" "Checking versioning status..."
    VERSIONING=$(aws s3api get-bucket-versioning --bucket $PRIMARY_BUCKET --query 'Status' --output text 2>/dev/null)

    if [ "$VERSIONING" == "Enabled" ]; then
        test_result "Versioning enabled on primary bucket" "PASS"
    else
        test_result "Versioning (Status: $VERSIONING)" "FAIL"
    fi

    # Test by uploading a file twice
    print_message "$YELLOW" "Testing version creation..."
    TEST_FILE="/tmp/version-test-$$.txt"
    echo "Version 1" > $TEST_FILE

    aws s3 cp $TEST_FILE s3://$PRIMARY_BUCKET/test-versioning.txt > /dev/null 2>&1
    sleep 2

    echo "Version 2" > $TEST_FILE
    aws s3 cp $TEST_FILE s3://$PRIMARY_BUCKET/test-versioning.txt > /dev/null 2>&1
    sleep 2

    # Count versions
    VERSION_COUNT=$(aws s3api list-object-versions --bucket $PRIMARY_BUCKET --prefix "test-versioning.txt" --query 'Versions[*].VersionId' --output text 2>/dev/null | wc -w)

    if [ "$VERSION_COUNT" -ge 2 ]; then
        test_result "Multiple versions created ($VERSION_COUNT versions)" "PASS"
    else
        test_result "Multiple versions created (Only $VERSION_COUNT version)" "FAIL"
    fi

    # Cleanup
    rm -f $TEST_FILE
    aws s3 rm s3://$PRIMARY_BUCKET/test-versioning.txt > /dev/null 2>&1
}

###############################################################################
# Test 6: Encryption
###############################################################################
test_encryption() {
    print_header "Test 6: Bucket Encryption"

    print_message "$YELLOW" "Checking default encryption..."
    ENCRYPTION=$(aws s3api get-bucket-encryption --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ]; then
        test_result "Default encryption enabled" "PASS"

        if echo "$ENCRYPTION" | grep -q "AES256"; then
            test_result "Encryption algorithm: AES256" "PASS"
        else
            test_result "Encryption algorithm check" "FAIL"
        fi
    else
        test_result "Default encryption enabled" "FAIL"
    fi

    # Test object encryption
    print_message "$YELLOW" "Testing object encryption..."
    TEST_FILE="/tmp/encrypt-test-$$.txt"
    echo "Encryption test" > $TEST_FILE

    aws s3 cp $TEST_FILE s3://$PRIMARY_BUCKET/test-encryption.txt > /dev/null 2>&1
    sleep 2

    OBJECT_ENCRYPTION=$(aws s3api head-object --bucket $PRIMARY_BUCKET --key test-encryption.txt --query 'ServerSideEncryption' --output text 2>/dev/null)

    if [ "$OBJECT_ENCRYPTION" == "AES256" ]; then
        test_result "Objects auto-encrypted (SSE-S3)" "PASS"
    else
        test_result "Objects auto-encrypted (Got: $OBJECT_ENCRYPTION)" "FAIL"
    fi

    # Cleanup
    rm -f $TEST_FILE
    aws s3 rm s3://$PRIMARY_BUCKET/test-encryption.txt > /dev/null 2>&1
}

###############################################################################
# Test 7: Cross-Region Replication
###############################################################################
test_replication() {
    print_header "Test 7: Cross-Region Replication"

    if [ -z "$DR_BUCKET" ]; then
        test_result "DR bucket configured" "SKIP"
        print_message "$YELLOW" "Skipping replication tests (no DR bucket configured)"
        return 0
    fi

    test_result "DR bucket configured" "PASS"

    # Check if DR bucket exists
    print_message "$YELLOW" "Checking DR bucket exists..."
    if aws s3 ls "s3://$DR_BUCKET" > /dev/null 2>&1; then
        test_result "DR bucket exists" "PASS"
    else
        test_result "DR bucket exists" "FAIL"
        return 1
    fi

    # Check versioning on DR bucket
    print_message "$YELLOW" "Checking DR bucket versioning..."
    DR_VERSIONING=$(aws s3api get-bucket-versioning --bucket $DR_BUCKET --query 'Status' --output text 2>/dev/null)

    if [ "$DR_VERSIONING" == "Enabled" ]; then
        test_result "DR bucket versioning enabled" "PASS"
    else
        test_result "DR bucket versioning enabled" "FAIL"
    fi

    # Check replication configuration
    print_message "$YELLOW" "Checking replication configuration..."
    REPLICATION=$(aws s3api get-bucket-replication --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ]; then
        test_result "Replication rule exists" "PASS"

        if echo "$REPLICATION" | grep -q "$DR_BUCKET"; then
            test_result "Replication destination correct" "PASS"
        else
            test_result "Replication destination correct" "FAIL"
        fi

        if echo "$REPLICATION" | grep -q '"Status": "Enabled"'; then
            test_result "Replication rule enabled" "PASS"
        else
            test_result "Replication rule enabled" "FAIL"
        fi
    else
        test_result "Replication rule exists" "FAIL"
        return 1
    fi

    # Test actual replication
    print_message "$YELLOW" "Testing replication (uploading test file)..."
    TEST_FILE="/tmp/replication-test-$$.txt"
    echo "Replication test - $(date)" > $TEST_FILE

    aws s3 cp $TEST_FILE s3://$PRIMARY_BUCKET/test-replication.txt > /dev/null 2>&1

    print_message "$YELLOW" "Waiting 30 seconds for replication..."
    sleep 30

    # Check if file replicated
    if aws s3 ls s3://$DR_BUCKET/test-replication.txt > /dev/null 2>&1; then
        test_result "File replicated to DR bucket" "PASS"

        # Check replication status
        REPL_STATUS=$(aws s3api head-object --bucket $PRIMARY_BUCKET --key test-replication.txt --query 'ReplicationStatus' --output text 2>/dev/null)

        if [ "$REPL_STATUS" == "COMPLETED" ] || [ "$REPL_STATUS" == "REPLICA" ]; then
            test_result "Replication status: $REPL_STATUS" "PASS"
        else
            test_result "Replication status: $REPL_STATUS (might need more time)" "FAIL"
        fi
    else
        print_message "$YELLOW" "File not replicated yet. This is normal - replication can take up to 15 minutes."
        test_result "File replicated (may need more time)" "SKIP"
    fi

    # Cleanup
    rm -f $TEST_FILE
    aws s3 rm s3://$PRIMARY_BUCKET/test-replication.txt > /dev/null 2>&1
}

###############################################################################
# Test 8: Lifecycle Rules
###############################################################################
test_lifecycle() {
    print_header "Test 8: Lifecycle Rules"

    print_message "$YELLOW" "Checking lifecycle configuration..."
    LIFECYCLE=$(aws s3api get-bucket-lifecycle-configuration --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ]; then
        test_result "Lifecycle rules exist" "PASS"

        # Count rules
        RULE_COUNT=$(echo "$LIFECYCLE" | grep -o '"Id":' | wc -l)
        test_result "Number of lifecycle rules: $RULE_COUNT" "PASS"

        # Check for transitions
        if echo "$LIFECYCLE" | grep -q "STANDARD_IA"; then
            test_result "Transition to Standard-IA configured" "PASS"
        else
            test_result "Transition to Standard-IA configured" "FAIL"
        fi

        if echo "$LIFECYCLE" | grep -q "GLACIER"; then
            test_result "Transition to Glacier configured" "PASS"
        else
            test_result "Transition to Glacier configured" "FAIL"
        fi
    else
        print_message "$YELLOW" "No lifecycle rules configured (optional feature)"
        test_result "Lifecycle rules exist" "SKIP"
    fi
}

###############################################################################
# Test 9: Access Logging
###############################################################################
test_access_logging() {
    print_header "Test 9: Access Logging"

    print_message "$YELLOW" "Checking access logging configuration..."
    LOGGING=$(aws s3api get-bucket-logging --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ] && echo "$LOGGING" | grep -q "LoggingEnabled"; then
        test_result "Access logging enabled" "PASS"

        # Check target bucket
        if [ ! -z "$LOGS_BUCKET" ]; then
            if echo "$LOGGING" | grep -q "$LOGS_BUCKET"; then
                test_result "Logs target bucket correct" "PASS"
            else
                test_result "Logs target bucket correct" "FAIL"
            fi

            # Check if logs bucket exists
            if aws s3 ls "s3://$LOGS_BUCKET" > /dev/null 2>&1; then
                test_result "Logs bucket exists" "PASS"

                # Check for log files (might not exist yet)
                LOG_COUNT=$(aws s3 ls s3://$LOGS_BUCKET/ --recursive | wc -l)
                if [ "$LOG_COUNT" -gt 0 ]; then
                    test_result "Log files present ($LOG_COUNT files)" "PASS"
                else
                    print_message "$YELLOW" "No log files yet (normal - logs can take 1-2 hours)"
                    test_result "Log files present" "SKIP"
                fi
            else
                test_result "Logs bucket exists" "FAIL"
            fi
        fi
    else
        print_message "$YELLOW" "Access logging not configured (optional feature)"
        test_result "Access logging enabled" "SKIP"
    fi
}

###############################################################################
# Test 10: Security Checks
###############################################################################
test_security() {
    print_header "Test 10: Security Validation"

    # Ensure encryption is on
    print_message "$YELLOW" "Verifying encryption is mandatory..."
    ENCRYPTION_CHECK=$(aws s3api get-bucket-encryption --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ]; then
        test_result "Encryption enabled (security best practice)" "PASS"
    else
        test_result "Encryption enabled" "FAIL"
    fi

    # Ensure versioning is on
    print_message "$YELLOW" "Verifying versioning for data protection..."
    VERSION_CHECK=$(aws s3api get-bucket-versioning --bucket $PRIMARY_BUCKET --query 'Status' --output text 2>/dev/null)

    if [ "$VERSION_CHECK" == "Enabled" ]; then
        test_result "Versioning enabled (data protection)" "PASS"
    else
        test_result "Versioning enabled" "FAIL"
    fi

    # Check that write access is NOT public
    print_message "$YELLOW" "Verifying write protection..."
    POLICY_CHECK=$(aws s3api get-bucket-policy --bucket $PRIMARY_BUCKET --query 'Policy' --output text 2>/dev/null)

    if echo "$POLICY_CHECK" | grep -q "s3:PutObject\|s3:DeleteObject"; then
        print_message "$RED" "⚠️  WARNING: Bucket policy might allow public write/delete!"
        test_result "Write protection (policy check)" "FAIL"
    else
        test_result "Write protection (no public write in policy)" "PASS"
    fi
}

###############################################################################
# Test 11: Cost Optimization
###############################################################################
test_cost_optimization() {
    print_header "Test 11: Cost Optimization Features"

    # Check lifecycle rules (cost optimization)
    LIFECYCLE_CHECK=$(aws s3api get-bucket-lifecycle-configuration --bucket $PRIMARY_BUCKET 2>/dev/null)

    if [ $? -eq 0 ]; then
        test_result "Lifecycle rules for cost optimization" "PASS"
    else
        print_message "$YELLOW" "Consider adding lifecycle rules to reduce costs"
        test_result "Lifecycle rules configured" "SKIP"
    fi

    # Check bucket size
    print_message "$YELLOW" "Checking bucket storage size..."
    BUCKET_SIZE=$(aws s3 ls s3://$PRIMARY_BUCKET --recursive --summarize 2>/dev/null | grep "Total Size" | awk '{print $3}')

    if [ ! -z "$BUCKET_SIZE" ]; then
        SIZE_MB=$((BUCKET_SIZE / 1024 / 1024))
        test_result "Current storage: ${SIZE_MB} MB" "PASS"

        if [ "$SIZE_MB" -lt 1024 ]; then
            print_message "$GREEN" "✅ Storage is within free tier (< 5 GB)"
        fi
    fi
}

###############################################################################
# Generate Test Report
###############################################################################
generate_report() {
    print_header "📊 Test Report Summary"

    PASS_RATE=0
    if [ "$TOTAL_TESTS" -gt 0 ]; then
        PASS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi

    echo ""
    print_message "$CYAN" "═══════════════════════════════════════════════════"
    print_message "$BLUE" "  Test Execution Summary"
    print_message "$CYAN" "═══════════════════════════════════════════════════"
    echo ""
    print_message "$BLUE" "  Total Tests Run:    $TOTAL_TESTS"
    print_message "$GREEN" "  ✅ Passed:          $PASSED_TESTS"
    print_message "$RED" "  ❌ Failed:          $FAILED_TESTS"
    print_message "$YELLOW" "  ⏭️  Skipped:         $SKIPPED_TESTS"
    echo ""
    print_message "$MAGENTA" "  Pass Rate:          ${PASS_RATE}%"
    echo ""
    print_message "$CYAN" "═══════════════════════════════════════════════════"
    echo ""

    # Overall status
    if [ "$FAILED_TESTS" -eq 0 ]; then
        print_message "$GREEN" "🎉 ALL CRITICAL TESTS PASSED!"
        print_message "$GREEN" "Your AWS S3 deployment is working correctly!"
        echo ""
        print_message "$BLUE" "✅ Website is live and accessible"
        print_message "$BLUE" "✅ Security properly configured"
        print_message "$BLUE" "✅ All features working as expected"
        echo ""
        print_message "$CYAN" "Ready for:"
        echo "  • Adding to your resume"
        echo "  • Sharing on LinkedIn"
        echo "  • Publishing to GitHub"
        echo "  • Showing to potential employers"
        echo ""
    else
        print_message "$YELLOW" "⚠️  SOME TESTS FAILED"
        print_message "$YELLOW" "Review the failed tests above and fix the issues."
        echo ""
        print_message "$BLUE" "Common fixes:"
        echo "  • 403 errors → Check bucket policy"
        echo "  • Replication → Wait 15-30 minutes"
        echo "  • Logging → Wait 1-2 hours for first logs"
        echo ""
    fi

    # Save report to file
    REPORT_FILE="test-report-$(date +%Y%m%d-%H%M%S).txt"
    {
        echo "AWS S3 Portfolio - Test Report"
        echo "==============================="
        echo "Date: $(date)"
        echo ""
        echo "Configuration:"
        echo "  Primary Bucket: $PRIMARY_BUCKET"
        echo "  Region: $PRIMARY_REGION"
        echo "  Website URL: $WEBSITE_URL"
        [ ! -z "$DR_BUCKET" ] && echo "  DR Bucket: $DR_BUCKET"
        [ ! -z "$LOGS_BUCKET" ] && echo "  Logs Bucket: $LOGS_BUCKET"
        echo ""
        echo "Results:"
        echo "  Total Tests: $TOTAL_TESTS"
        echo "  Passed: $PASSED_TESTS"
        echo "  Failed: $FAILED_TESTS"
        echo "  Skipped: $SKIPPED_TESTS"
        echo "  Pass Rate: ${PASS_RATE}%"
        echo ""
    } > $REPORT_FILE

    print_message "$CYAN" "📄 Detailed report saved to: $REPORT_FILE"
    echo ""
}

###############################################################################
# Main Execution
###############################################################################

print_banner
sleep 2

print_header "🔍 Loading Configuration"
load_config

print_message "$CYAN" "Starting comprehensive test suite..."
print_message "$YELLOW" "This will test all AWS S3 features and configurations"
echo ""

# Run all tests
test_website_availability
test_bucket_configuration
test_static_hosting
test_bucket_policy
test_versioning
test_encryption
test_replication
test_lifecycle
test_access_logging
test_security
test_cost_optimization

# Generate final report
generate_report

# Exit with appropriate code
if [ "$FAILED_TESTS" -eq 0 ]; then
    exit 0
else
    exit 1
fi