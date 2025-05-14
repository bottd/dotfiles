#!/usr/bin/env bash
# Test script for NixOS configuration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Log functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Test functions
test_flake_check() {
  log_info "Testing flake.nix with 'nix flake check'..."
  if nix flake check; then
    log_info "Flake check passed."
    return 0
  else
    log_error "Flake check failed."
    return 1
  fi
}

test_flake_show() {
  log_info "Testing flake outputs with 'nix flake show'..."
  if nix flake show; then
    log_info "Flake show passed."
    return 0
  else
    log_error "Flake show failed."
    return 1
  fi
}

test_nixos_build() {
  local host=$1
  log_info "Testing NixOS build for host: $host"
  if nixos-rebuild build --flake .#$host --show-trace; then
    log_info "NixOS build for $host passed."
    return 0
  else
    log_error "NixOS build for $host failed."
    return 1
  fi
}

test_darwin_build() {
  local host=$1
  log_info "Testing Darwin build for host: $host"
  if darwin-rebuild build --flake .#$host --show-trace; then
    log_info "Darwin build for $host passed."
    return 0
  else
    log_error "Darwin build for $host failed."
    return 1
  fi
}

test_home_manager_build() {
  local host=$1
  log_info "Testing Home Manager build for host: $host"
  if home-manager build --flake .#$host --show-trace; then
    log_info "Home Manager build for $host passed."
    return 0
  else
    log_error "Home Manager build for $host failed."
    return 1
  fi
}

test_format() {
  log_info "Testing Nix formatting with treefmt..."
  if nix run .#formatter -- --fail-on-change; then
    log_info "Formatting check passed."
    return 0
  else
    log_error "Formatting check failed. Run 'nix run .#formatter' to fix."
    return 1
  fi
}

# Run tests based on arguments
run_tests() {
  # Set default values
  local all=false
  local flake_check=false
  local flake_show=false
  local nixos_build=false
  local nixos_host="desktop"
  local darwin_build=false
  local darwin_host="macbook"
  local home_build=false
  local home_host="desktop"
  local format=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --all)
        all=true
        shift
        ;;
      --flake-check)
        flake_check=true
        shift
        ;;
      --flake-show)
        flake_show=true
        shift
        ;;
      --nixos)
        nixos_build=true
        if [[ $# -gt 1 ]] && [[ ! $2 =~ ^-- ]]; then
          nixos_host=$2
          shift
        fi
        shift
        ;;
      --darwin)
        darwin_build=true
        if [[ $# -gt 1 ]] && [[ ! $2 =~ ^-- ]]; then
          darwin_host=$2
          shift
        fi
        shift
        ;;
      --home)
        home_build=true
        if [[ $# -gt 1 ]] && [[ ! $2 =~ ^-- ]]; then
          home_host=$2
          shift
        fi
        shift
        ;;
      --format)
        format=true
        shift
        ;;
      *)
        log_error "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  # If no specific tests are requested, run the basic tests
  if [[ $all == false ]] && [[ $flake_check == false ]] && [[ $flake_show == false ]] && \
     [[ $nixos_build == false ]] && [[ $darwin_build == false ]] && \
     [[ $home_build == false ]] && [[ $format == false ]]; then
    flake_check=true
    flake_show=true
  fi

  # If --all is specified, run all tests
  if [[ $all == true ]]; then
    flake_check=true
    flake_show=true
    nixos_build=true
    darwin_build=true
    home_build=true
    format=true
  fi

  # Run the requested tests
  local failed=false

  if [[ $flake_check == true ]]; then
    if ! test_flake_check; then
      failed=true
    fi
  fi

  if [[ $flake_show == true ]]; then
    if ! test_flake_show; then
      failed=true
    fi
  fi

  if [[ $nixos_build == true ]]; then
    if ! test_nixos_build "$nixos_host"; then
      failed=true
    fi
  fi

  if [[ $darwin_build == true ]]; then
    if ! test_darwin_build "$darwin_host"; then
      failed=true
    fi
  fi

  if [[ $home_build == true ]]; then
    if ! test_home_manager_build "$home_host"; then
      failed=true
    fi
  fi

  if [[ $format == true ]]; then
    if ! test_format; then
      failed=true
    fi
  fi

  if [[ $failed == true ]]; then
    log_error "One or more tests failed."
    exit 1
  else
    log_info "All tests passed successfully."
    exit 0
  fi
}

# Print usage information
print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --all                Run all tests"
  echo "  --flake-check        Run 'nix flake check'"
  echo "  --flake-show         Run 'nix flake show'"
  echo "  --nixos [host]       Test NixOS build for host (default: desktop)"
  echo "  --darwin [host]      Test Darwin build for host (default: macbook)"
  echo "  --home [host]        Test Home Manager build for host (default: desktop)"
  echo "  --format             Test Nix formatting with treefmt"
  echo
  echo "If no options are specified, --flake-check and --flake-show are run."
  exit 0
}

# Main
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
  print_usage
else
  run_tests "$@"
fi