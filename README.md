# AWS DevOps Mastery - Terraform Repository

> **Enterprise-Grade Infrastructure as Code** with parallel security scanning, multi-repository OIDC, and environment-specific approval workflows.

## 🎯 Current Status

**Repository:** `aws-devops-mastery-terraform`  
**Purpose:** Infrastructure code separated from application code  
**Workflows Implemented:** `dev-plan.yml` ✅  
**Workflows Pending:** `dev-apply.yml`, `staging-plan.yml`, `staging-apply.yml`, `production-plan.yml`, `production-apply.yml`

### ✅ Completed

- [x] Separate terraform repository created
- [x] OIDC configured for multi-repository authentication
- [x] Bootstrap updated with `github_repositories` list
- [x] dev-plan.yml workflow with parallel security scanning
- [x] Branch protection rules enforcing PR workflow
- [x] Infracost integration for cost estimation
- [x] CODEOWNERS file for approval gates
- [x] Full git history fetching for gitleaks

### 🚧 In Progress

- [ ] dev-apply.yml (auto-deploy after merge to main)
- [ ] staging-plan.yml (comprehensive scans: +Checkov +Terrascan)
- [ ] staging-apply.yml (manual approval required)
- [ ] production-plan.yml (full compliance scanning)
- [ ] production-apply.yml (2 approvals + change ticket)

---

## 📋 Table of Contents

- [Why Separate Repositories](#why-separate-repositories)
- [Repository Structure](#repository-structure)
- [Security Scanning Workflows](#security-scanning-workflows)
- [OIDC Multi-Repository Setup](#oidc-multi-repository-setup)
- [Branch Protection](#branch-protection)
- [Getting Started](#getting-started)

---

## Why Separate Repositories?

**🔒 Security & Access Control:**
- Platform team owns infrastructure (terraform repo)
- Developers own application code (app repo)
- Different approval requirements (production infra needs 2+ approvals)

**📊 Blast Radius Reduction:**
- Failed infrastructure changes don't block app deployments
- Failed app builds don't block infrastructure updates

**⚡ CI/CD Performance:**
- Infrastructure workflows only run when infrastructure changes
- App builds don't wait for infra security scans (6-15 min!)

---

## Repository Structure

**Application Repository:** [`aws-devops-mastery`](https://github.com/chrisjamaica91/aws-devops-mastery)
- Microservice code (JavaScript, Java, Rust)
- CI/CD: Build images, run tests, push to ECR
- Branch: `staging`

**Infrastructure Repository:** [`aws-devops-mastery-terraform`](https://github.com/chrisjamaica91/aws-devops-mastery-terraform)
- All Terraform code (bootstrap, modules, environments)
- CI/CD: Security scans, plan/apply workflows
- Branch: `main`

**GitOps Repository:** `aws-devops-mastery-gitops` (future)
- Kubernetes manifests
- ArgoCD syncs deployments from this repo

---

### Terraform Repository File Structure

```
aws-devops-mastery-terraform/
├── .github/
│   ├── CODEOWNERS                    # Approval requirements per environment
│   └── workflows/
│       ├── dev-plan.yml              # Dev environment security scanning + plan
│       ├── dev-apply.yml             # Dev environment infrastructure deployment
│       ├── staging-plan.yml          # Staging environment (with Checkov + Terrascan)
│       ├── staging-apply.yml         # Staging deployment (manual approval)
│       ├── production-plan.yml       # Production (comprehensive scans + 2 approvals)
│       └── production-apply.yml      # Production deployment (2 approvals + change ticket)
│
├── terraform/
│   ├── bootstrap/
│   │   ├── main.tf                   # OIDC provider + state buckets
│   │   ├── variables.tf
│   │   ├── terraform.tfvars          # Multiple GitHub repositories configured
│   │   └── terraform.tfstate         # Local state (bootstrap only)
│   │
│   ├── modules/
│   │   ├── github-oidc/              # GitHub Actions OIDC authentication
│   │   │   ├── main.tf               # OIDC provider creation
│   │   │   ├── roles.tf              # IAM roles with multi-repo trust policy
│   │   │   └── policies.tf           # Least privilege IAM policies
│   │   ├── terraform-state/          # S3 + native locking for state management
│   │   ├── vpc/                      # Multi-AZ VPC with public/private subnets
│   │   └── eks/                      # EKS cluster with Karpenter support
│   │
│   └── environments/
│       ├── dev/
│       │   ├── backend.tf           # S3 backend with native locking
│       │   ├── main.tf              # Dev-specific resource configuration
│       │   ├── terraform.tfvars     # Dev environment variables
│       │   └── variables.tf
│       ├── staging/                  # Staging environment
│       └── production/               # Production environment
│
├── .gitignore                        # Excludes .terraform/, *.tfstate
└── README.md                         # Infrastructure documentation
```

---

## Security Scanning Workflows

### Multi-Layer Security Strategy

Different environments have different security thoroughness levels:

| Environment | Scan Duration | Tools | Purpose |
|-------------|---------------|-------|---------|
| **Dev** | ~60-90 sec | gitleaks, TFLint, tfsec | Fast developer feedback |
| **Staging** | ~4-6 min | Dev tools + Checkov (CIS), Terrascan | Pre-production validation |
| **Production** | ~10-15 min | All tools + full Checkov frameworks, 2 approvals | Zero-tolerance security |

### Security Tools Breakdown

**🔐 gitleaks** (5-10 seconds)
- **Purpose:** Detect hardcoded secrets (API keys, passwords, tokens)
- **Action:** Blocks PR immediately if secrets found
- **Why:** Prevents credential exposure before code review
- **Example:** Detects `AWS_SECRET_ACCESS_KEY=abc123` in code

**🔍 TFLint** (10-20 seconds)
- **Purpose:** Terraform syntax and best practices
- **Checks:** Deprecated syntax, invalid variable references, provider version constraints
- **Action:** Blocks PR on errors (warnings allowed)
- **Example:** Detects using deprecated `aws_instance` arguments

**🛡️ tfsec** (10-30 seconds)
- **Purpose:** AWS-specific security misconfigurations
- **Checks:** S3 bucket encryption, security group rules, IAM policies
- **Severity:** Blocks on MEDIUM+ (configurable)
- **Example:** Detects publicly accessible S3 bucket

**✅ Checkov** (1-3 minutes) - Staging/Production only
- **Purpose:** Multi-framework compliance scanning
- **Frameworks:** CIS AWS, PCI-DSS, HIPAA, SOC 2, NIST
- **Coverage:** 1000+ policy checks across cloud providers
- **Example:** Enforces CIS AWS Foundations Benchmark controls

**🌐 Terrascan** (1-2 minutes) - Staging/Production only
- **Purpose:** Multi-cloud IaC security scanning
- **Checks:** Cross-cloud best practices, compliance violations
- **Benefit:** Catches patterns tfsec might miss
- **Example:** Detects non-compliant encryption algorithms

**💰 Infracost** (30 seconds)
- **Purpose:** Cost estimation before deployment
- **Output:** Monthly cost estimate + cost delta
- **Benefit:** Prevents surprise billing (especially important for production)
- **Example:** "This change will increase costs by $150/month"

---

## Branch Protection Rules

### Main Branch Protection Configuration

**Repository:** `aws-devops-mastery-terraform`  
**Branch:** `main`

**Required Settings:**

```yaml
Branch Protection Rules:
  ✅ Require a pull request before merging
    ✅ Require approvals: 1 (can be 0 for solo projects)
    ✅ Dismiss stale pull request approvals when new commits are pushed
    ✅ Require review from Code Owners (if CODEOWNERS file exists)

  ✅ Require status checks to pass before merging
    ✅ Require branches to be up to date before merging
    Required checks:
      - 🔐 Detect Secrets
      - 🔍 Lint Terraform
      - 🛡️ Security Scan
      - 📋 Plan Infrastructure Changes

  ✅ Require conversation resolution before merging
    (All PR comments must be resolved)

  ✅ Do not allow bypassing the above settings
    (Even repo admins must follow rules)

  ✅ Include administrators
    (No exceptions for anyone)
```

### CODEOWNERS File

**Purpose:** Enforce approval requirements based on file paths

**Location:** `.github/CODEOWNERS`

**Example Configuration:**

```
# All infrastructure changes require platform team review
* @platform-team

# Staging environment requires platform leads
/terraform/environments/staging/** @platform-leads

# Production requires platform leads + engineering directors (2 approvals)
/terraform/environments/production/** @platform-leads @engineering-directors

# Bootstrap changes require 2 senior engineers (state infrastructure is critical)
/terraform/bootstrap/** @senior-platform-engineers @senior-platform-engineers

# Modules require architecture review
/terraform/modules/** @platform-architects
```

### What This Prevents

❌ **Direct pushes to main** - All changes via Pull Request  
❌ **Merging without security scans passing** - gitleaks/tfsec/TFLint must pass  
❌ **Merging with unresolved comments** - Forces discussion resolution  
❌ **Bypassing rules** - Even admins follow the process  
❌ **Deploying without review** - Code owner approval required  

---

## OIDC Multi-Repository Setup

### Problem

When you create a second repository (`aws-devops-mastery-terraform`), the original OIDC trust policy only allows the first repository (`aws-devops-mastery`). GitHub Actions from the new repo get rejected:

```
Error: Not authorized to perform sts:AssumeRoleWithWebIdentity
```

### Solution: Multi-Repository Trust Policy

**Update Bootstrap Configuration:**

**File:** `terraform/bootstrap/terraform.tfvars`

```hcl
# Before (single repository)
github_repository = "chrisjamaica91/aws-devops-mastery"

# After (multiple repositories)
github_repositories = [
  "chrisjamaica91/aws-devops-mastery",
  "chrisjamaica91/aws-devops-mastery-terraform"
]
```

**File:** `terraform/modules/github-oidc/roles.tf`

```hcl
# Updated IAM role trust policy
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Support multiple repositories
          "token.actions.githubusercontent.com:sub" = [
            for repo in var.github_repositories : "repo:${repo}:*"
          ]
        }
      }
    }
  ]
})
```

**Apply Changes:**

```bash
cd terraform/bootstrap
terraform plan   # Review changes
terraform apply  # Update IAM role trust policy
```

**Result:** Both repositories can now authenticate to AWS using OIDC!

---

## Workflow Architecture

### dev-plan.yml - Parallel Security Scanning

**Purpose:** Fast security feedback on infrastructure PRs  
**Trigger:** Pull request to `main` branch changing `terraform/environments/dev/**` or `terraform/modules/**`  
**Duration:** ~60-90 seconds (parallel execution)

#### Job Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│  Pull Request Created (changes to dev/** or modules/*)  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
    ┌────────────────────────────────────┐
    │   Workflow Triggered: dev-plan.yml │
    └────────────┬───────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│              PARALLEL EXECUTION (Jobs 1-3)             │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐│
│  │ JOB 1:       │  │ JOB 2:       │  │ JOB 3:       ││
│  │ Secrets Scan │  │ Linting      │  │ Security     ││
│  │              │  │              │  │ Scanning     ││
│  │ • Checkout   │  │ • Checkout   │  │ • Checkout   ││
│  │ • gitleaks   │  │ • Terraform  │  │ • Terraform  ││
│  │              │  │   init       │  │   init       ││
│  │ Time: 5-10s  │  │ • TFLint     │  │ • tfsec      ││
│  │              │  │              │  │              ││
│  │              │  │ Time: 15-20s │  │ Time: 20-30s ││
│  └──────────────┘  └──────────────┘  └──────────────┘│
│                                                        │
│  All jobs run simultaneously on separate runners      │
└────────────┬───────────────────────────────────────────┘
             │
             │ ✅ All 3 jobs must pass
             ▼
┌────────────────────────────────────────────────────────┐
│         JOB 4: Terraform Plan (waits for jobs 1-3)    │
│                                                        │
│  needs: [secrets-scan, lint, security]                │
│                                                        │
│  Steps:                                                │
│  1. Checkout code (fetch-depth: 0)                    │
│  2. Setup Terraform 1.9.0                             │
│  3. Configure AWS (OIDC authentication)               │
│  4. terraform init                                     │
│  5. terraform validate                                 │
│  6. terraform fmt -check -recursive                    │
│  7. terraform plan (output to tfplan file)            │
│  8. Setup Infracost                                    │
│  9. Generate cost estimate from plan                   │
│  10. Post PR comment with:                             │
│      • Security scan results from jobs 1-3            │
│      • Terraform plan output                          │
│      • Cost estimate (monthly + delta)                │
│      • Next steps for reviewer                        │
│  11. Upload tfplan artifact (for apply workflow)       │
│  12. Generate workflow summary                         │
│                                                        │
│  Time: ~60 seconds                                     │
└────────────────────────────────────────────────────────┘
```

#### Key Workflow Features

**✅ Parallel Execution:**
- Jobs 1-3 run simultaneously (not sequentially)
- Total time = longest job (~30 sec) instead of sum of all jobs (~50 sec)
- Saves 40% execution time vs sequential

**✅ Early Failure Detection:**
- If gitleaks finds secrets, other jobs are cancelled immediately
- Prevents wasting runner minutes on failed PRs
- Developer gets immediate feedback

**✅ Full Git History:**
- `fetch-depth: 0` ensures gitleaks can scan commit range
- Prevents "unknown revision" errors from shallow clones
- Required for historical secret detection

**✅ Cost Visibility:**
- Infracost shows cost BEFORE deploying
- Example: "+$171/month if merged" (prevents surprise bills)
- Optional if API key not configured

**✅ Comprehensive PR Comment:**
- Shows results from ALL jobs in single comment
- Easy for reviewers to see complete picture
- Includes plan output, costs, and next steps

#### Permissions Required

```yaml
permissions:
  contents: read              # Read repository code
  pull-requests: write        # Post PR comments
  security-events: write      # Upload security scan results
  id-token: write             # OIDC token generation (AWS authentication)
```

#### Environment-Specific Differences

**Dev Workflow (`dev-plan.yml`):**
- Fast scans only (gitleaks, TFLint, tfsec)
- No Checkov or Terrascan (time optimization)
- 0-1 approval required
- ~60-90 second execution time

**Staging Workflow (`staging-plan.yml`):** (to be created)
- All dev scans PLUS:
  - Checkov with CIS AWS framework
  - Terrascan for compliance
- 1-2 approvals required
- ~4-6 minute execution time

**Production Workflow (`production-plan.yml`):** (to be created)
- All staging scans PLUS:
  - Full Checkov frameworks (PCI-DSS, HIPAA, SOC 2, NIST)
  - Manual approval gate (GitHub Environments)
  - Change ticket reference required
- 2+ approvals required (platform lead + engineering director)
- ~10-15 minute execution time

---

## Next Steps for Students

### 1. Clone and Set Up

```bash
# Clone the terraform repository
git clone https://github.com/YOUR_USERNAME/aws-devops-mastery-terraform.git
cd aws-devops-mastery-terraform

# Review the structure
ls -la terraform/
```

### 2. Configure Bootstrap

```bash
cd terraform/bootstrap

# Edit terraform.tfvars with your repository names
nano terraform.tfvars

# Initialize and apply
terraform init
terraform apply
```

### 3. Set Up GitHub Secrets

1. Get Infracost API key: https://dashboard.infracost.io/
2. Add to GitHub: Settings → Secrets → Actions → New repository secret
3. Name: `INFRACOST_API_KEY`
4. Value: Your API key

### 4. Configure Branch Protection

1. Go to: Settings → Branches → Add branch protection rule
2. Branch name pattern: `main`
3. Enable all recommended settings (see [Branch Protection Rules](#branch-protection-rules))
4. Add required status checks after first workflow run

### 5. Test the Workflow

```bash
# Create a test branch
git checkout -b test/dev-workflow

# Make a small change
echo "# Test" >> terraform/environments/dev/terraform.tfvars

# Commit and push
git add .
git commit -m "test: trigger dev-plan workflow"
git push origin test/dev-workflow

# Create PR on GitHub and watch workflow execute
```

### 6. Verify Security Scanning

Watch for:
- ✅ All 4 jobs complete successfully
- ✅ PR comment appears with plan output and costs
- ✅ Merge button blocked until all checks pass
- ✅ Workflow summary visible in Actions tab

---

## Troubleshooting

### Common Issues

**1. "Not authorized to perform sts:AssumeRoleWithWebIdentity"**
- **Cause:** IAM role trust policy doesn't include your repository
- **Fix:** Update `terraform/bootstrap/terraform.tfvars` to include all repositories, then `terraform apply`

**2. "fatal: ambiguous argument (unknown revision)"**
- **Cause:** Shallow git clone, gitleaks can't access commit history
- **Fix:** Add `fetch-depth: 0` to checkout step

**3. "Terraform exited with code 3" (format check)**
- **Cause:** `.tf` files not properly formatted
- **Fix:** Run `terraform fmt -recursive` locally, commit changes

**4. "INFRACOST_API_KEY is not set"**
- **Cause:** Missing Infracost API key in GitHub Secrets
- **Fix:** Add API key or make Infracost steps conditional: `if: secrets.INFRACOST_API_KEY != ''`

**5. "Merge button available even though checks failed"**
- **Cause:** Branch protection not configured
- **Fix:** Enable branch protection with required status checks

---

## Best Practices

### ✅ DO

- **Separate repositories** for infrastructure and application code
- **Test workflows** on feature branches before merging to main
- **Use parallel jobs** for independent security scans (saves time)
- **Enable branch protection** immediately (prevents accidental direct pushes)
- **Review Infracost output** before merging (prevent cost surprises)
- **Use CODEOWNERS** for environment-specific approvals
- **Keep bootstrap state local** (chicken and egg problem)
- **Use remote state** for all other environments

### ❌ DON'T

- **Don't commit `.terraform/` directories** (add to .gitignore)
- **Don't commit `*.tfstate` files** (contains sensitive data)
- **Don't bypass branch protection** (defeats the purpose)
- **Don't skip security scans** to save time (security is non-negotiable)
- **Don't use permanent AWS access keys** (use OIDC instead)
- **Don't allow direct pushes to main** (all changes via PR)
- **Don't merge PRs with unresolved conversations**

---

## Summary

This terraform repository architecture provides:

- ✅ **Enterprise-grade security** with multi-layer scanning
- ✅ **Fast developer feedback** via parallel execution
- ✅ **Cost visibility** before deployment
- ✅ **Compliance enforcement** via automated checks
- ✅ **Audit trail** through Git history and PR reviews
- ✅ **Blast radius reduction** via repository separation
- ✅ **Production-ready patterns** used by FAANG companies

Students following this guide will build muscle memory for infrastructure patterns used at top tech companies, preparing them for Senior/Lead Platform Engineer roles ($180k-$300k+).

