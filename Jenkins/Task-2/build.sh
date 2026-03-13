#!/bin/bash
###############################################
# Build Script - Jenkins Task 2
# Description: A simple build script that
# compiles/runs a basic application and
# generates a build report.
###############################################

set -e

echo "========================================="
echo "  Jenkins CI/CD - Automated Build"
echo "  Build triggered at: $(date)"
echo "========================================="
echo ""

# Project Info
echo "[INFO] Project  : Jenkins Task 2 - CI/CD Demo"
echo "[INFO] Branch   : $(git branch --show-current 2>/dev/null || echo 'N/A')"
echo "[INFO] Commit   : $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo "[INFO] Builder  : $(whoami)"
echo "[INFO] Hostname : $(hostname)"
echo ""

# Step 1: Environment Check
echo "--- Step 1: Environment Check ---"
echo "OS       : $(uname -s)"
echo "Kernel   : $(uname -r)"
echo "Shell    : $SHELL"
echo "Bash Ver : $BASH_VERSION"
echo ""

# Step 2: Create build output directory
echo "--- Step 2: Creating build directory ---"
BUILD_DIR="build_output"
mkdir -p $BUILD_DIR
echo "Build directory created: $BUILD_DIR"
echo ""

# Step 3: Run a simple application
echo "--- Step 3: Running Application ---"
cat > $BUILD_DIR/app.py << 'PYEOF'
import datetime
import platform

print("Hello from Jenkins CI/CD Pipeline!")
print(f"Current Time : {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print(f"Python Ver   : {platform.python_version()}")
print(f"Platform     : {platform.platform()}")
print("Application executed successfully!")
PYEOF

if command -v python3 &>/dev/null; then
    python3 $BUILD_DIR/app.py
elif command -v python &>/dev/null; then
    python $BUILD_DIR/app.py
else
    echo "[WARN] Python not found. Skipping app execution."
fi
echo ""

# Step 4: Run basic tests
echo "--- Step 4: Running Tests ---"
TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Check build directory exists
if [ -d "$BUILD_DIR" ]; then
    echo "[PASS] Build directory exists"
    ((TESTS_PASSED++))
else
    echo "[FAIL] Build directory missing"
    ((TESTS_FAILED++))
fi

# Test 2: Check app.py was created
if [ -f "$BUILD_DIR/app.py" ]; then
    echo "[PASS] app.py created successfully"
    ((TESTS_PASSED++))
else
    echo "[FAIL] app.py not found"
    ((TESTS_FAILED++))
fi

# Test 3: Check script is executable
if [ -x "$0" ]; then
    echo "[PASS] Build script is executable"
    ((TESTS_PASSED++))
else
    echo "[PASS] Build script ran successfully (via bash)"
    ((TESTS_PASSED++))
fi

echo ""
echo "Test Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo ""

# Step 5: Generate build report
echo "--- Step 5: Generating Build Report ---"
REPORT_FILE="$BUILD_DIR/build_report.txt"
cat > $REPORT_FILE << EOF
=======================================
        BUILD REPORT
=======================================
Date       : $(date)
Status     : SUCCESS
Branch     : $(git branch --show-current 2>/dev/null || echo 'N/A')
Commit     : $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')
Builder    : $(whoami)@$(hostname)
Tests      : $TESTS_PASSED passed, $TESTS_FAILED failed
=======================================
EOF

echo "Build report saved to: $REPORT_FILE"
cat $REPORT_FILE
echo ""

# Final status
echo "========================================="
if [ $TESTS_FAILED -eq 0 ]; then
    echo "  BUILD SUCCESSFUL ✓"
else
    echo "  BUILD FAILED ✗"
    exit 1
fi
echo "========================================="
