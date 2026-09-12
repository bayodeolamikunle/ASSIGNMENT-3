#!/bin/bash

# Assignment 3 Grader
# CI/CD with GitHub Actions

PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "========================================"
echo "Assignment 3 - CI/CD Grader"
echo "========================================"
echo

# ----------------------------------------
# 1. Repository Structure
# ----------------------------------------

echo "Checking repository structure..."

required_files=(
    "README.md"
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    ".github/workflows/ci.yml"
    "Dockerfile"
    "compose.yaml"
    ".dockerignore"
    "grade.sh"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        pass "Required file exists: $file"
    else
        fail "Missing required file: $file"
    fi
done

echo

# ----------------------------------------
# 2. Executable Permissions
# ----------------------------------------

echo "Checking executable permissions..."

executable_files=(
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "grade.sh"
)

for file in "${executable_files[@]}"; do
    if [[ -x "$file" ]]; then
        pass "Executable: $file"
    else
        fail "Not executable: $file"
    fi
done

echo

# ----------------------------------------
# 3. Bash Syntax
# ----------------------------------------

echo "Checking Bash syntax..."

bash_files=(
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "grade.sh"
)

for file in "${bash_files[@]}"; do
    if bash -n "$file" 2>/dev/null; then
        pass "Bash syntax valid: $file"
    else
        fail "Bash syntax error: $file"
    fi
done

echo

# ----------------------------------------
# 4. Application Behaviour
# ----------------------------------------

echo "Checking application behaviour..."

APP="./app/app.sh"

# Help
if "$APP" help >/dev/null 2>&1; then
    pass "help command works"
else
    fail "help command failed"
fi

# system-info
if "$APP" system-info >/dev/null 2>&1; then
    pass "system-info command works"
else
    fail "system-info command failed"
fi

# Invalid command must return 2
"$APP" invalid-command >/dev/null 2>&1
status=$?

if [[ $status -eq 2 ]]; then
    pass "invalid command returns exit code 2"
else
    fail "invalid command returned exit code $status instead of 2"
fi

# Missing host
"$APP" check-host >/dev/null 2>&1
status=$?

if [[ $status -eq 2 ]]; then
    pass "missing host returns exit code 2"
else
    fail "missing host returned exit code $status instead of 2"
fi

# Valid host
if "$APP" check-host localhost >/dev/null 2>&1; then
    pass "valid host check works"
else
    fail "valid host check failed"
fi

# Missing port
"$APP" check-port localhost >/dev/null 2>&1
status=$?

if [[ $status -eq 2 ]]; then
    pass "missing port returns exit code 2"
else
    fail "missing port returned exit code $status instead of 2"
fi

# Non-numeric port
"$APP" check-port localhost abc >/dev/null 2>&1
status=$?

if [[ $status -eq 2 ]]; then
    pass "non-numeric port returns exit code 2"
else
    fail "non-numeric port returned exit code $status instead of 2"
fi

# Port below range
"$APP" check-port localhost 0 >/dev/null 2>&1
status=$?

if [[ $status -eq 2 ]]; then
    pass "port 0 returns exit code 2"
else
    fail "port 0 returned exit code $status instead of 2"
fi

# Port above range
"$APP" check-port localhost 65536 >/dev/null 2>&1
status=$?

if [[ $status -eq 2 ]]; then
    pass "port 65536 returns exit code 2"
else
    fail "port 65536 returned exit code $status instead of 2"
fi

echo

# ----------------------------------------
# 5. Linting
# ----------------------------------------

echo "Running linting..."

if ./scripts/lint.sh >/dev/null 2>&1; then
    pass "lint.sh passed"
else
    fail "lint.sh failed"
fi

echo

# ----------------------------------------
# 6. Student Tests
# ----------------------------------------

echo "Running student tests..."

if ./tests/test.sh; then
    pass "student test suite passed"
else
    fail "student test suite failed"
fi

echo

# ----------------------------------------
# 7. Docker
# ----------------------------------------

echo "Checking Docker..."

if ! command -v docker >/dev/null 2>&1; then
    fail "Docker is not installed"
else
    pass "Docker command is available"

    if docker info >/dev/null 2>&1; then
        pass "Docker daemon is running"

        echo "Building Docker image..."

        if docker build -t devops-tool . >/dev/null; then
            pass "Docker image builds successfully"

            if docker run --rm devops-tool help >/dev/null 2>&1; then
                pass "Docker help smoke test passed"
            else
                fail "Docker help smoke test failed"
            fi

            if docker run --rm devops-tool system-info >/dev/null 2>&1; then
                pass "Docker system-info smoke test passed"
            else
                fail "Docker system-info smoke test failed"
            fi

            docker run --rm devops-tool invalid-command >/dev/null 2>&1
            status=$?

            if [[ $status -eq 2 ]]; then
                pass "Docker invalid-command test returns exit code 2"
            else
                fail "Docker invalid-command returned exit code $status"
            fi

        else
            fail "Docker image build failed"
        fi

    else
        fail "Docker daemon is not running"
    fi
fi

echo

# ----------------------------------------
# 8. GitHub Actions Workflow
# ----------------------------------------

echo "Checking GitHub Actions workflow..."

WORKFLOW=".github/workflows/ci.yml"

if grep -Eq '(^|[[:space:]])push:' "$WORKFLOW"; then
    pass "workflow contains push trigger"
else
    fail "workflow missing push trigger"
fi

if grep -Eq '(^|[[:space:]])pull_request:' "$WORKFLOW"; then
    pass "workflow contains pull_request trigger"
else
    fail "workflow missing pull_request trigger"
fi

# Required jobs
if grep -Eq '^[[:space:]]*validate:' "$WORKFLOW"; then
    pass "validate job exists"
else
    fail "validate job missing"
fi

if grep -Eq '^[[:space:]]*test:' "$WORKFLOW"; then
    pass "test job exists"
else
    fail "test job missing"
fi

if grep -Eq '^[[:space:]]*docker:' "$WORKFLOW"; then
    pass "docker job exists"
else
    fail "docker job missing"
fi

# Dependencies
if grep -A10 -E '^[[:space:]]*test:' "$WORKFLOW" | grep -q 'needs:.*validate'; then
    pass "test depends on validate"
else
    fail "test does not depend on validate"
fi

if grep -A10 -E '^[[:space:]]*docker:' "$WORKFLOW" | grep -q 'needs:.*test'; then
    pass "docker depends on test"
else
    fail "docker does not depend on test"
fi

# Lint command
if grep -q './scripts/lint.sh' "$WORKFLOW"; then
    pass "workflow runs lint.sh"
else
    fail "workflow does not run lint.sh"
fi

# Test command
if grep -q './tests/test.sh' "$WORKFLOW"; then
    pass "workflow runs test.sh"
else
    fail "workflow does not run test.sh"
fi

# Docker build script
if grep -q './scripts/build.sh' "$WORKFLOW"; then
    pass "workflow runs build.sh"
else
    fail "workflow does not run build.sh"
fi

echo

# ----------------------------------------
# 9. Docker Build Script
# ----------------------------------------

echo "Checking Docker build script..."

if grep -q 'docker build' scripts/build.sh; then
    pass "build.sh contains Docker build"
else
    fail "build.sh does not contain Docker build"
fi

if grep -q 'docker run' scripts/build.sh; then
    pass "build.sh contains Docker smoke tests"
else
    fail "build.sh does not contain Docker smoke tests"
fi

if grep -q 'invalid-command' scripts/build.sh; then
    pass "build.sh contains invalid-command smoke test"
else
    fail "build.sh missing invalid-command smoke test"
fi

echo

# ----------------------------------------
# 10. Git History
# ----------------------------------------

echo "Checking Git history..."

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    pass "Git repository detected"

    commit_count=$(git rev-list --count HEAD 2>/dev/null)

    if [[ "$commit_count" -ge 2 ]]; then
        pass "Git history contains multiple commits"
    else
        fail "Git history should contain multiple meaningful commits"
    fi

    if git log --oneline --all | grep -qiE 'ci|test|docker|docs|fix'; then
        pass "Git history contains meaningful assignment commits"
    else
        fail "Git history does not show meaningful assignment commits"
    fi
else
    fail "Not a Git repository"
fi

echo

# ----------------------------------------
# Final Result
# ----------------------------------------

echo "========================================"
echo "Assignment 3 Grading Summary"
echo "========================================"

echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"

echo "========================================"

if [[ $FAIL -eq 0 ]]; then
    echo "ALL GRADER CHECKS PASSED."
    exit 0
else
    echo "SOME GRADER CHECKS FAILED."
    exit 1
fi
