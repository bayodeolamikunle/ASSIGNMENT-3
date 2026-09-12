#!/bin/bash

set -e

IMAGE_NAME="devops-tool"

echo "Building Docker image: $IMAGE_NAME"

docker build -t "$IMAGE_NAME" .

echo
echo "Running Docker smoke tests..."

echo "Test 1: help"
docker run --rm "$IMAGE_NAME" help

echo
echo "Test 2: system-info"
docker run --rm "$IMAGE_NAME" system-info

echo
echo "Test 3: invalid command"

set +e
docker run --rm "$IMAGE_NAME" invalid-command
status=$?
set -e

if [[ "$status" -ne 2 ]]; then
    echo "ERROR: Invalid command returned exit code $status, expected 2."
    exit 1
fi

echo "Invalid command correctly returned exit code 2."

echo
echo "Docker build and smoke tests passed."
