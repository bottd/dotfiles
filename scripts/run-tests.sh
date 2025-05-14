#!/usr/bin/env bash
# Script to run tests for the configuration

set -euo pipefail

# Make scripts executable
chmod +x scripts/test.sh

# Run the test script with all tests
scripts/test.sh --all