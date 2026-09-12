#!/bin/bash

set -e

echo "Running repository structure checks..."

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
    if [[ ! -f "$file" ]]; then
        echo "ERROR: Required file missing: $file"
        exit 1
    fi
done

echo "All required files exist."

echo
echo "Running Bash syntax checks..."

bash_scripts=(
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "grade.sh"
)

for script in "${bash_scripts[@]}"; do
    echo "Checking: $script"
    bash -n "$script"
done

echo
echo "Bash syntax checks passed."
echo "Linting passed."
