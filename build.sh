#!/usr/bin/env bash
# Compiles the C backend.
set -e
cd "$(dirname "$0")"
if ! command -v gcc >/dev/null 2>&1; then
  echo "gcc not found. Install it with:  sudo apt install build-essential"; exit 1
fi
gcc -Wall -Wextra -O2 backend/backend.c -o backend/os_backend -pthread
echo "Build successful: backend/os_backend"
