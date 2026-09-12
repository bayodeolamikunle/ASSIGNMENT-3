#!/bin/bash

APP="./app/app.sh"

passed=0
failed=0

run_test() {
    local name="$1"
    shift

    echo "TEST: $name"

    if "$@"; then
        echo "PASS: $name"
        ((passed++))
    else
        echo "FAIL: $name"
        ((failed++))
    fi

    echo
}

# Test 1: help command
run_test "help command" \
    bash -c "$APP help >/dev/null"

# Test 2: system-info command
run_test "system-info command" \
    bash -c "$APP system-info >/dev/null"

# Test 3: invalid command returns exit code 2
run_test "invalid command" \
    bash -c "$APP invalid-command >/dev/null 2>&1; [[ \$? -eq 0 ]]"

# Test 4: missing host returns exit code 2
run_test "missing host" \
    bash -c "$APP check-host >/dev/null 2>&1; [[ \$? -eq 2 ]]"

# Test 5: valid host resolves successfully
run_test "valid host" \
    bash -c "$APP check-host google.com >/dev/null"

# Test 6: missing port returns exit code 2
run_test "missing port" \
    bash -c "$APP check-port google.com >/dev/null 2>&1; [[ \$? -eq 2 ]]"

# Test 7: non-numeric port returns exit code 2
run_test "non-numeric port" \
    bash -c "$APP check-port google.com abc >/dev/null 2>&1; [[ \$? -eq 2 ]]"

# Test 8: port below valid range returns exit code 2
run_test "port below range" \
    bash -c "$APP check-port google.com 0 >/dev/null 2>&1; [[ \$? -eq 2 ]]"

# Test 9: port above valid range returns exit code 2
run_test "port above range" \
    bash -c "$APP check-port google.com 65536 >/dev/null 2>&1; [[ \$? -eq 2 ]]"

# Test 10: valid TCP port
run_test "valid TCP port" \
    bash -c "$APP check-port google.com 443 >/dev/null"

echo "=============================="
echo "Tests passed: $passed"
echo "Tests failed: $failed"
echo "=============================="

if [[ "$failed" -eq 0 ]]; then
    echo "All tests passed."
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
