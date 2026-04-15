# Module Versioning - Implementation Guide

## Overview

This guide walks you through implementing module versioning in your terraform project.

## Current State

- Dev, staging, and production all use: `source = "../../modules/vpc"`
- This means all environments use the SAME code at the SAME time
- If you change a module, all environments are affected immediately

## Goal State

- Dev uses: `source = "git::https://github.com/you/repo.git//terraform/modules/vpc?ref=vpc-v1.1.0"`
- Staging uses: `source = "git::https://github.com/you/repo.git//terraform/modules/vpc?ref=vpc-v1.0.0"`
- Production uses: `source = "git::https://github.com/you/repo.git//terraform/modules/vpc?ref=vpc-v1.0.0"`
- Each environment can use different versions
- You control when each environment upgrades

---

## Implementation Steps

### Step 1: Create Initial Tags (Bookmarks)

**What:** Create version tags for your current module code
**Why:** This creates v1.0.0 snapshots you can reference later

**Commands to run:**

```powershell
# Make sure you're on main branch and up to date
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git checkout main && git pull'

# Create tags for current module versions
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git tag vpc-v1.0.0 -m "VPC module v1.0.0 - Initial release"'

wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git tag eks-v1.0.0 -m "EKS module v1.0.0 - Initial release"'

wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git tag ecr-v1.0.0 -m "ECR module v1.0.0 - Initial release"'

# Push tags to GitHub
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git push origin vpc-v1.0.0 eks-v1.0.0 ecr-v1.0.0'
```

**Verify:** Go to GitHub repository → Click "releases" or "tags" → You should see vpc-v1.0.0, eks-v1.0.0, ecr-v1.0.0

---

### Step 2: Update Dev Environment to Use Versioned Modules

**What:** Change dev/main.tf to pull modules from Git tags instead of local folders
**Why:** This makes dev use the "vpc-v1.0.0" bookmark instead of the current folder

**File:** `terraform/environments/dev/main.tf`

**Find this:**

```hcl
module "vpc" {
  source = "../../modules/vpc"
```

**Change to:**

```hcl
module "vpc" {
  source = "git::https://github.com/chrisjamaica91/aws-devops-mastery-terraform.git//terraform/modules/vpc?ref=vpc-v1.0.0"
```

**Do the same for EKS module:**

**Find:**

```hcl
module "eks" {
  source = "../../modules/eks"
```

**Change to:**

```hcl
module "eks" {
  source = "git::https://github.com/chrisjamaica91/aws-devops-mastery-terraform.git//terraform/modules/eks?ref=eks-v1.0.0"
```

**And ECR module:**

**Find:**

```hcl
module "ecr" {
  source = "../../modules/ecr"
```

**Change to:**

```hcl
module "ecr" {
  source = "git::https://github.com/chrisjamaica91/aws-devops-mastery-terraform.git//terraform/modules/ecr?ref=ecr-v1.0.0"
```

---

### Step 3: Test That It Works

**What:** Verify terraform can download modules from GitHub
**Why:** Make sure the versioning setup is correct

**Commands:**

```powershell
# Delete old module cache
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform/terraform/environments/dev && rm -rf .terraform .terraform.lock.hcl'

# Initialize terraform (will download modules from GitHub)
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform/terraform/environments/dev && terraform init'
```

**Expected output:**

```
Initializing modules...
Downloading git::https://github.com/chrisjamaica91/aws-devops-mastery-terraform.git?ref=vpc-v1.0.0 for vpc...
Downloading git::https://github.com/chrisjamaica91/aws-devops-mastery-terraform.git?ref=eks-v1.0.0 for eks...
Downloading git::https://github.com/chrisjamaica91/aws-devops-mastery-terraform.git?ref=ecr-v1.0.0 for ecr...
- vpc in .terraform/modules/vpc/terraform/modules/vpc
- eks in .terraform/modules/eks/terraform/modules/eks
- ecr in .terraform/modules/ecr/terraform/modules/ecr
```

If you see "Downloading git::" - **SUCCESS!** ✅

---

### Step 4: Update Staging and Production (Same Way)

Repeat Step 2 for:

- `terraform/environments/staging/main.tf`
- `terraform/environments/production/main.tf`

All three environments start on v1.0.0.

---

### Step 5: Commit Your Changes

```powershell
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git add terraform/environments/*/main.tf'

wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git commit -m "feat: implement module versioning using Git tags"'

wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git push'
```

---

## Testing Version Upgrades (Later)

Once versioning is set up, this is how you test a new version:

### Scenario: Update VPC Module

1. **Make changes to terraform/modules/vpc/**
2. **Commit the changes**
3. **Create new tag:** `git tag vpc-v1.1.0 -m "New feature"`
4. **Push tag:** `git push origin vpc-v1.1.0`
5. **Update dev only:** Change dev/main.tf to use `ref=vpc-v1.1.0`
6. **Test in dev**
7. **If successful, update staging:** Change staging/main.tf to `ref=vpc-v1.1.0`
8. **Test in staging**
9. **If successful, update production:** Change production/main.tf to `ref=vpc-v1.1.0`

At any point, each environment can be on different versions!

---

## Quick Reference

**View all tags:**

```powershell
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git tag -l'
```

**Create new tag:**

```powershell
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git tag MODULE-v1.1.0 -m "Description"'
wsl bash -c 'cd ~/projects/aws-devops/aws-devops-mastery-terraform && git push origin MODULE-v1.1.0'
```

**Rollback (if new version breaks):**
Just change the version number back:

```hcl
# In dev/main.tf
# Change from:
source = "git::...?ref=vpc-v1.1.0"
# Back to:
source = "git::...?ref=vpc-v1.0.0"
```

---

## Ready to Start?

Follow the steps above in order. Stop after each step and verify it worked before moving to the next step.

Good luck! 🚀
