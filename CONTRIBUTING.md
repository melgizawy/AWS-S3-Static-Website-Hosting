# Contributing to AWS S3 Portfolio Project

First off, thank you for considering contributing to this project! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)

## 📜 Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [dr.gizawy@cu.edu.eg].

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and expected**
- **Include screenshots if possible**
- **Include your environment details** (OS, AWS CLI version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the enhancement**
- **Explain why this enhancement would be useful**
- **List any alternative solutions you've considered**

### Pull Requests

- Fill in the required template
- Follow the style guidelines
- Include appropriate test cases
- Update documentation as needed
- Ensure all tests pass

## 🚀 Getting Started

### Prerequisites

```bash
# Install AWS CLI
# macOS
brew install awscli
# Windows/Linux - see AWS documentation
# Verify installation
aws --version
```

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/AWS-S3-Static-Website-Hosting-project.git
cd AWS-S3-Static-Website-Hosting-project
# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/AWS-S3-Static-Website-Hosting-project.git
```

### Create a Branch

```bash
# Create a new branch for your work
git checkout -b feature/your-feature-name
# Or for bug fixes
git checkout -b fix/bug-description
```

## 🔄 Pull Request Process

1. **Update Documentation**: Ensure README and other docs reflect your changes
2. **Add Tests**: If applicable, add tests for your changes
3. **Update CHANGELOG**: Add your changes to CHANGELOG.md
4. **Test Locally**: Ensure everything works on your local setup
5. **Push Changes**: Push to your fork
6. **Create PR**: Submit a pull request with a clear description

### PR Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing

- [ ] Tested locally
- [ ] All tests pass
- [ ] Documentation updated

## Screenshots (if applicable)

Add screenshots here
```

## 📝 Style Guidelines

### Bash Scripts

```bash
#!/bin/bash
# Always use strict mode
set -e
# Use meaningful variable names
PRIMARY_BUCKET="my-website-bucket"
# Add comments for complex logic
# This function checks if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not installed"
        exit 1
    fi
}
# Use functions for reusable code
main() {
    check_aws_cli
    # Rest of the script
}
main "$@"
```

### HTML/CSS

```html
<!-- Use semantic HTML -->
<header>
  <nav>
    <!-- Navigation content -->
  </nav>
</header>
<!-- Use meaningful class names -->
<div class="feature-card">
  <h3 class="feature-title">Title</h3>
</div>
```

```css
/* Use CSS variables */
:root {
  --primary-color: #ff9900;
}
/* Follow BEM naming convention (optional) */
.feature-card {
}
.feature-card__title {
}
.feature-card--highlighted {
}
/* Add comments for complex styles */
/* Mobile responsive breakpoint */
@media (max-width: 768px) {
  /* Styles */
}
```

### JSON

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bucket-name/*"
    }
  ]
}
```

## 💬 Commit Messages

### Format

```
type(scope): subject
body (optional)
footer (optional)
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```bash
feat(scripts): add automated backup script
Add a new script to automate S3 bucket backups with
configurable retention policies.
Closes #123
```

```bash
fix(deployment): correct content-type for CSS files
CSS files were being served with incorrect MIME type,
causing browsers to not apply styles correctly.
```

```bash
docs(readme): update installation instructions
Add detailed steps for Windows users and troubleshooting
section for common AWS CLI issues.
```

## 🧪 Testing

Before submitting a PR:

```bash
# Test scripts
cd scripts/setup
./create-buckets.sh
# Verify website loads
# Check console for errors
# Test on mobile devices
```

## 📚 Additional Resources

- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [Git Best Practices](https://git-scm.com/book/en/v2)

## ❓ Questions?

Feel free to open an issue with your question or reach out to the maintainers.

## 🎉 Thank You!

## Your contributions make this project better for everyone. Thank you for taking the time to contribute!

**Happy Contributing! 🚀**
