#!/bin/bash
# Wrapper script to run cacti from any directory or via symlink.
# Please run make to build the cacti executable first.
#
# The cacti executable depends on data files with relative paths:
#   - tech_params/*.dat  (technology parameter files)
#   - contention.dat     (contention statistics)
#
# Therefore, cacti must be run from its installation directory.
# This wrapper script handles that automatically.

# Save the current working directory to resolve relative file paths
ORIG_DIR="$(pwd)"

# Resolve the real path of this script (handles symlinks)
SOURCE="$0"
while [ -L "$SOURCE" ]; do
    DIR="$(cd "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    # If SOURCE is relative, resolve it relative to the symlink's directory
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd "$(dirname "$SOURCE")" && pwd)"

# Convert any relative file paths in arguments to absolute paths
ARGS=()
for arg in "$@"; do
    if [[ "$arg" != -* ]] && [[ -e "$ORIG_DIR/$arg" ]]; then
        # This looks like a file path that exists - make it absolute
        ARGS+=("$ORIG_DIR/$arg")
    elif [[ "$arg" != -* ]] && [[ -e "$arg" ]]; then
        # Already absolute or exists as-is
        ARGS+=("$(cd "$(dirname "$arg")" && pwd)/$(basename "$arg")")
    else
        ARGS+=("$arg")
    fi
done

# Change to the script directory and run cacti with converted arguments
cd "$SCRIPT_DIR" && ./cacti "${ARGS[@]}"
