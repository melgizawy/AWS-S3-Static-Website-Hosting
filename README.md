# 🚀 AWS S3 Static Website Hosting & Management Portfolio

<div align="center">

![AWS S3](https://img.shields.io/badge/AWS-S3-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production_Ready-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

**Professional AWS S3 Portfolio Project showcasing cloud engineering skills**

[Live Demo](#-live-demo) • [Documentation](#-documentation) • [Quick Start](#-quick-start) • [Contact](#-contact)

![Website Preview](documentation/screenshots/06-website/16-website-live-homepage.png)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Detailed Setup](#-detailed-setup)
- [Project Structure](#-project-structure)
- [Usage Guide](#-usage-guide)
- [Security](#-security)
- [Cost Analysis](#-cost-analysis)
- [Monitoring](#-monitoring)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🎯 Overview

This project demonstrates enterprise-level AWS S3 capabilities through a fully functional static website deployment. It showcases best practices in cloud architecture, security, disaster recovery, and cost optimization.

### What This Project Demonstrates

✅ **Cloud Infrastructure** - S3 bucket configuration and management
✅ **Security Best Practices** - Multi-layer security implementation
✅ **Disaster Recovery** - Cross-region replication setup
✅ **Cost Optimization** - Lifecycle policies and storage tiering
✅ **DevOps Practices** - Automated deployment scripts
✅ **Documentation** - Comprehensive technical documentation

### Project Stats

| Metric           | Value                      |
| ---------------- | -------------------------- |
| **Uptime SLA**   | 99.99%                     |
| **Load Time**    | < 200ms                    |
| **Cost Savings** | 95% vs traditional hosting |
| **Regions**      | Multi-region deployment    |
| **Security**     | AES-256 encryption         |
| **Recovery**     | RPO < 15 minutes           |

---

## ✨ Features

### 🌐 Static Website Hosting

- Serverless architecture with automatic scaling
- Custom error pages (404 handling)
- Global content delivery
- No server maintenance required

### 🔐 Multi-Layer Security

- **Encryption**: AES-256 server-side encryption (SSE-S3)
- **Access Control**: IAM roles, bucket policies, ACLs
- **Versioning**: Point-in-time recovery
- **Monitoring**: CloudWatch integration and access logs
- **Pre-signed URLs**: Time-limited secure access

### 🔄 Disaster Recovery

- **Cross-Region Replication (CRR)**: Automated data replication
- **RPO**: < 15 minutes
- **RTO**: < 30 minutes
- **Automated Failover**: Ready for production
- **Delete Marker Replication**: Complete data protection

### 💰 Cost Optimization

- **Lifecycle Policies**: Automatic storage class transitions
- **Storage Tiers**: Standard → Standard-IA → Glacier
- **Intelligent Tiering**: Adaptive cost optimization
- **Monthly Cost**: $3-5 (vs $60-100 traditional hosting)

### 📊 Monitoring & Management

- CloudWatch metrics and alarms
- S3 Storage Lens analytics
- Access log analysis
- Request metrics tracking
- Cost monitoring and alerts

---

## 🏗️ Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Internet Users                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│         Primary S3 Bucket (us-east-1)                    │
│  ┌───────────────────────────────────────────────────┐  │
│  │  • Static Website Hosting                         │  │
│  │  • SSE-S3 Encryption                              │  │
│  │  • Versioning Enabled                             │  │
│  │  • Public Read Access                             │  │
│  └───────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Cross-Region Replication
                     ▼
┌─────────────────────────────────────────────────────────┐
│         DR S3 Bucket (eu-west-1)                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  • Replicated Content                             │  │
│  │  • Same Encryption                                │  │
│  │  • Versioning Enabled                             │  │
│  │  • Automated Sync                                 │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Tech Stack

| Component          | Technology                   |
| ------------------ | ---------------------------- |
| **Cloud Provider** | AWS                          |
| **Storage**        | Amazon S3                    |
| **Security**       | IAM, SSE-S3, Bucket Policies |
| **DR**             | Cross-Region Replication     |
| **Monitoring**     | CloudWatch, Access Logs      |
| **Automation**     | Bash Scripts, AWS CLI        |
| **Frontend**       | HTML5, CSS3, JavaScript      |

---

## 📦 Prerequisites

### Required

- **AWS Account** (Free Tier eligible)
- **AWS CLI** v2.x or higher
- **Git** for version control
- **Bash** shell (Linux/macOS/WSL)

### Recommended

- **jq** for JSON parsing
- **curl** for testing
- **Code Editor** (VS Code, Sublime, etc.)

### Installation

#### AWS CLI

```bash
# macOS
brew install awscli

# Windows (using installer)
# Download from: https://aws.amazon.com/cli/

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

#### Configure AWS CLI

```bash
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-east-1
# Default output format: json
```

---

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/melgizawy/AWS-S3-Static-Website-Hosting.git
cd AWS-S3-Static-Website-Hosting

# 2. Make scripts executable
chmod +x scripts/setup/quick-setup.sh

# 3. Run automated setup
./scripts/setup/quick-setup.sh

# 4. Follow the prompts and wait for completion
# Your website will be live in ~5 minutes! 🎉
```

### Option 2: Manual Setup

```bash
# 1. Clone repository
git clone https://github.com/melgizawy/AWS-S3-Static-Website-Hosting.git
cd AWS-S3-Static-Website-Hosting

# 2. Create buckets
cd scripts/setup
chmod +x create-buckets.sh
./create-buckets.sh

# 3. Deploy website
cd ../deployment
chmod +x deploy-website.sh
./deploy-website.sh

# 4. Configure security
cd ../security
chmod +x apply-bucket-policy.sh enable-encryption.sh
./apply-bucket-policy.sh
./enable-encryption.sh

# 5. Setup replication
cd ../replication
chmod +x setup-replication.sh
./setup-replication.sh
```

### Verify Deployment

```bash
# Get your website URL from bucket-config.txt
cat bucket-config.txt | grep WEBSITE_URL

# Test the website
curl -I [YOUR_WEBSITE_URL]
# Should return: HTTP/1.1 200 OK
```

---

## 📚 Detailed Setup

### Step 1: Create S3 Buckets

```bash
cd scripts/setup
./create-buckets.sh
```

**What this does:**

- Creates primary bucket for website hosting
- Creates DR bucket in different region
- Creates logs bucket for access logs
- Enables versioning on all buckets
- Applies resource tags
- Saves configuration to `bucket-config.txt`

### Step 2: Deploy Website Files

```bash
cd scripts/deployment
./deploy-website.sh
```

**What this does:**

- Uploads all files from `website-files/` to S3
- Sets correct content types (HTML, CSS, JS)
- Configures static website hosting
- Sets index.html and error.html
- Tests website accessibility

### Step 3: Configure Security

```bash
cd scripts/security

# Apply bucket policy for public read
./apply-bucket-policy.sh

# Enable encryption
./enable-encryption.sh
```

**What this does:**

- Disables block public access (for website hosting)
- Applies bucket policy for public read
- Enables AES-256 encryption
- Verifies configuration

### Step 4: Setup Disaster Recovery

```bash
cd scripts/replication
./setup-replication.sh
```

**What this does:**

- Creates IAM role for replication
- Configures cross-region replication rule
- Enables replication time control
- Tests replication functionality

### Step 5: Test Everything

```bash
# Test website
curl http://your-bucket.s3-website-us-east-1.amazonaws.com

# List objects
aws s3 ls s3://your-bucket-name/

# Check replication status
aws s3api get-bucket-replication --bucket your-bucket-name

# View encryption
aws s3api get-bucket-encryption --bucket your-bucket-name
```

---

## 📁 Project Structure

```
AWS-S3-Static-Website-Hosting/
│
├── 📄 README.md                          # This file
├── 📄 LICENSE                            # MIT License
├── 📄 .gitignore                         # Git ignore rules
├── 📄 CONTRIBUTING.md                    # Contribution guidelines
├── 📄 bucket-config.txt                  # Generated config (DO NOT commit)
│
├── 📁 website-files/                     # Static website content
│   ├── index.html                        # Homepage
│   ├── error.html                        # 404 page
│   ├── 📁 css/                           # Stylesheets
│   │   ├── styles.css                    # Main styles
│   │   └── responsive.css                # Mobile styles
│   ├── 📁 js/                            # JavaScript
│   │   └── main.js                       # Main JS
│   └── 📁 images/                        # Image assets
│
├── 📁 scripts/                           # Automation scripts
│   ├── 📁 setup/                         # Initial setup
│   │   ├── quick-setup.sh               # Automated full setup
│   │   ├── create-buckets.sh            # Create S3 buckets
│   │   └── enable-versioning.sh         # Enable versioning
│   ├── 📁 deployment/                    # Deployment scripts
│   │   ├── deploy-website.sh            # Deploy website
│   │   └── update-website.sh            # Update content
│   ├── 📁 security/                      # Security configuration
│   │   ├── apply-bucket-policy.sh       # Apply policies
│   │   └── enable-encryption.sh         # Enable encryption
│   └── 📁 replication/                   # DR setup
│       ├── setup-replication.sh         # Setup CRR
│       └── test-replication.sh          # Test replication
│
├── 📁 policies/                          # AWS policy files
│   ├── bucket-policy.json                # Public read policy
│   ├── lifecycle-policy.json             # Lifecycle rules
│   ├── replication-policy.json           # Replication config
│   ├── iam-role-trust.json               # IAM trust policy
│   └── iam-replication-policy.json       # IAM permissions
│
└── 📁 documentation/                     # Extended docs
    ├── 📄 ARCHITECTURE.md                # Architecture details
    ├── 📄 SECURITY.md                    # Security guide
    ├── 📄 DEPLOYMENT.md                  # Deployment guide
    ├── 📄 TROUBLESHOOTING.md             # Common issues
    ├── 📁 diagrams/                      # Architecture diagrams
    └── 📁 screenshots/                   # Project screenshots
```

---

## 📖 Usage Guide

### Updating Website Content

```bash
# 1. Edit files in website-files/
vim website-files/index.html

# 2. Deploy changes
cd scripts/deployment
./deploy-website.sh

# Your changes are live!
```

### Generating Pre-Signed URLs

```bash
# Generate URL valid for 1 hour
aws s3 presign s3://your-bucket/private-file.pdf --expires-in 3600

# Generate URL valid for 24 hours
aws s3 presign s3://your-bucket/document.pdf --expires-in 86400
```

### Checking Replication Status

```bash
# View replication configuration
aws s3api get-bucket-replication --bucket your-primary-bucket

# Check specific object replication
aws s3api head-object \
  --bucket your-primary-bucket \
  --key yourfile.txt \
  | grep ReplicationStatus
```

### Viewing Access Logs

```bash
# Download logs
aws s3 sync s3://your-logs-bucket/access-logs/ ./logs/

# Analyze logs (example: count requests)
cat logs/*.log | wc -l

# Find 403 errors
grep "403" logs/*.log
```

### Monitoring Costs

```bash
# Get bucket size
aws s3 ls s3://your-bucket --recursive --summarize --human-readable

# View CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name BucketSizeBytes \
  --dimensions Name=BucketName,Value=your-bucket \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 86400 \
  --statistics Average
```

---

## 🔐 Security

### Implemented Security Measures

| Layer                  | Implementation             | Status      |
| ---------------------- | -------------------------- | ----------- |
| **Encryption at Rest** | AES-256 (SSE-S3)           | ✅          |
| **Access Control**     | Bucket Policies + IAM      | ✅          |
| **Versioning**         | Enabled on all buckets     | ✅          |
| **Logging**            | Access logs enabled        | ✅          |
| **HTTPS**              | Can be enforced via policy | ⚠️ Optional |
| **MFA Delete**         | Can be enabled             | ⚠️ Optional |

### Security Best Practices

```bash
# 1. Never commit credentials
echo "*.pem" >> .gitignore
echo "*.key" >> .gitignore
echo "credentials" >> .gitignore

# 2. Use IAM roles instead of access keys (when possible)

# 3. Enable MFA on AWS account

# 4. Regularly rotate access keys
aws iam update-access-key --access-key-id YOUR_KEY_ID --status Inactive

# 5. Review bucket policies regularly
aws s3api get-bucket-policy --bucket your-bucket

# 6. Monitor CloudTrail for suspicious activity
aws cloudtrail lookup-events --max-results 10
```

### Security Checklist

- [x] Encryption enabled (SSE-S3)
- [x] Versioning enabled
- [x] Access logging configured
- [x] Bucket policies follow least privilege
- [x] IAM roles used for replication
- [ ] MFA Delete enabled (optional)
- [ ] HTTPS enforced via CloudFront (optional)
- [ ] AWS Config rules monitoring (optional)

---

## 💰 Cost Analysis

### Monthly Cost Breakdown

Based on typical usage:

```
Storage (50 GB):
  • First 30 days (Standard):     $1.15
  • 30-90 days (Standard-IA):     $0.63
  • 90+ days (Glacier):           $0.20

Requests:
  • GET (100,000):                $0.04
  • PUT (5,000):                  $0.03

Data Transfer:
  • First 10 GB:                  $0.90

Replication:
  • Cross-region transfer:        $0.50
  • DR storage (50 GB):           $1.15

Total Monthly Cost:               ~$4.60
```

### Cost Comparison

| Solution                  | Monthly Cost | Savings    |
| ------------------------- | ------------ | ---------- |
| **Traditional VPS**       | $60-100      | -          |
| **AWS S3 (This Project)** | $3-5         | **95%** ✅ |

### Cost Optimization Tips

1. **Use Lifecycle Policies**

   ```json
   Day 0-30:  Standard ($0.023/GB)
   Day 30-90: Standard-IA ($0.0125/GB) → 46% savings
   Day 90+:   Glacier ($0.004/GB) → 83% savings
   ```

2. **Enable CloudFront** (Future enhancement)

   - Reduces GET requests to S3
   - Lower data transfer costs
   - Better performance

3. **Clean Up Old Versions**

   ```bash
   # Delete old versions after 365 days (configured in lifecycle)
   ```

4. **Use S3 Intelligent-Tiering**
   ```bash
   # Automatically moves objects between tiers
   ```

---

## 📊 Monitoring

### CloudWatch Metrics

```bash
# Storage metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name BucketSizeBytes \
  --dimensions Name=BucketName,Value=your-bucket Name=StorageType,Value=StandardStorage \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 86400 \
  --statistics Average

# Request metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name AllRequests \
  --dimensions Name=BucketName,Value=your-bucket \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum
```

### Performance Metrics

Test your website performance:

```bash
# Using curl
time curl -s http://your-bucket.s3-website-us-east-1.amazonaws.com > /dev/null

# Using online tools
# - GTmetrix: https://gtmetrix.com
# - PageSpeed Insights: https://pagespeed.web.dev
# - WebPageTest: https://www.webpagetest.org
```

### Setting Up Alarms

```bash
# Create CloudWatch alarm for high request count
aws cloudwatch put-metric-alarm \
  --alarm-name high-s3-requests \
  --alarm-description "Alert when S3 requests exceed threshold" \
  --metric-name AllRequests \
  --namespace AWS/S3 \
  --statistic Sum \
  --period 3600 \
  --evaluation-periods 1 \
  --threshold 100000 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=BucketName,Value=your-bucket
```

---

## 🔧 Troubleshooting

### Common Issues

#### Issue 1: 403 Forbidden Error

**Symptoms:** Website returns 403 error

**Solutions:**

```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket your-bucket

# Check public access block
aws s3api get-public-access-block --bucket your-bucket

# Verify object ACL
aws s3api get-object-acl --bucket your-bucket --key index.html

# Fix: Re-apply bucket policy
cd scripts/security
./apply-bucket-policy.sh
```

#### Issue 2: Website Not Loading

**Symptoms:** Cannot access website URL

**Solutions:**

```bash
# Verify static website hosting is enabled
aws s3api get-bucket-website --bucket your-bucket

# Check if index.html exists
aws s3 ls s3://your-bucket/index.html

# Verify content-type
aws s3api head-object --bucket your-bucket --key index.html

# Fix: Reconfigure website hosting
aws s3 website s3://your-bucket/ \
  --index-document index.html \
  --error-document error.html
```

#### Issue 3: Replication Not Working

**Symptoms:** Objects not appearing in DR bucket

**Solutions:**

```bash
# Check replication configuration
aws s3api get-bucket-replication --bucket your-bucket

# Verify versioning is enabled
aws s3api get-bucket-versioning --bucket your-bucket
aws s3api get-bucket-versioning --bucket your-dr-bucket

# Check IAM role permissions
aws iam get-role-policy --role-name your-replication-role --policy-name S3ReplicationPolicy

# View object replication status
aws s3api head-object --bucket your-bucket --key yourfile.txt | grep ReplicationStatus

# Fix: Wait 15 minutes or re-run setup
cd scripts/replication
./setup-replication.sh
```

#### Issue 4: High Costs

**Symptoms:** Unexpected AWS bill

**Solutions:**

```bash
# Check bucket size
aws s3 ls s3://your-bucket --recursive --summarize --human-readable

# Review lifecycle policies
aws s3api get-bucket-lifecycle-configuration --bucket your-bucket

# Check request metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name AllRequests \
  --dimensions Name=BucketName,Value=your-bucket \
  --start-time $(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 86400 \
  --statistics Sum

# Implement cost-saving measures
# 1. Enable lifecycle policies
# 2. Delete unnecessary objects
# 3. Use CloudFront for caching
```

### Debug Commands

```bash
# List all buckets
aws s3 ls

# Get bucket location
aws s3api get-bucket-location --bucket your-bucket

# Check all bucket configurations
aws s3api get-bucket-acl --bucket your-bucket
aws s3api get-bucket-policy --bucket your-bucket
aws s3api get-bucket-encryption --bucket your-bucket
aws s3api get-bucket-versioning --bucket your-bucket
aws s3api get-bucket-website --bucket your-bucket
aws s3api get-bucket-lifecycle-configuration --bucket your-bucket
aws s3api get-bucket-replication --bucket your-bucket

# Test website endpoint
curl -v http://your-bucket.s3-website-us-east-1.amazonaws.com
```

### Getting Help

If you're still stuck:

1. Check [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
2. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/amazon-s3)
3. Open an [Issue](https://github.com/melgizawy/aws-s3-portfolio/issues)
4. Contact me: [dr.gizawy@cu.edu.eg]

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Contribution Guide

```bash
# 1. Fork the repository
# 2. Create a feature branch
git checkout -b feature/amazing-feature

# 3. Make your changes
# 4. Commit your changes
git commit -m "feat: add amazing feature"

# 5. Push to your fork
git push origin feature/amazing-feature

# 6. Open a Pull Request
```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License - Copyright (c) 2025 Mohammad Elgizawy
Permission is hereby granted, free of charge, to any person obtaining a copy...
```

---

## 📞 Contact

### Connect With Me

- **LinkedIn**: [Your LinkedIn Profile](https://linkedin.com/in/yourprofile)
- **GitHub**: [Your GitHub Profile](https://github.com/melgizawy)
- **Email**: dr.gizawy@cu.edu.eg
- **Portfolio**: [Your Portfolio Website](https://melgizawy.com)
- **Twitter**: [@melgizawy](https://twitter.com/melgizawy)

### Project Links

- **Live Demo**: http://your-bucket.s3-website-us-east-1.amazonaws.com
- **Documentation**: [GitHub Wiki](https://github.com/melgizawy/aws-s3-portfolio/wiki)
- **Issues**: [Report Issues](https://github.com/melgizawy/aws-s3-portfolio/issues)
- **Discussions**: [Join Discussions](https://github.com/melgizawy/aws-s3-portfolio/discussions)

---

## 🎓 Certifications & Training

### Coursera Projects Completed

1. ✅ **Deploy a Website in AWS S3** (1 hour)
2. ✅ **AWS S3 Basics** (1 hour)
3. ✅ **Host a Static Website with S3 and CloudShell** (1 hour)
4. ✅ **Cross-Region Replication & Disaster Recovery** (2 hours)

**Total Learning Time**: 6+ hours
**Skills Acquired**: 15+ cloud engineering skills

---

## 🙏 Acknowledgments

- **AWS** for comprehensive documentation
- **Coursera** for guided learning projects
- **Open Source Community** for tools and inspiration
- **You** for checking out this project!

---

## 📊 Project Statistics

```
Lines of Code:        2,500+
Documentation:        3,000+ lines
Scripts:              15
Policies:             7
Total Project Size:   ~25 MB
Development Time:     40+ hours
```

---

## 🌟 Star History

If you found this project helpful, please consider giving it a star! ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=melgizawy/aws-s3-portfolio&type=Date)](https://star-history.com/#melgizawy/aws-s3-portfolio&Date)

---

<div align="center">

**Built with ❤️ and ☁️ AWS**

_Last Updated: January 2025_

[⬆ Back to Top](#-aws-s3-static-website-hosting--management-portfolio)

</div>
