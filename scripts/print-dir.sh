#!/usr/bin/env bash
set -euo pipefail

print_usage() {
    cat <<EOF
Usage: $(basename "$0") [-d max_depth] [-i include_pattern] [-e exclude_pattern] [-s] [-f format] [-m max_size] directory_path

Options:
  -d max_depth       Maximum recursion depth (default: unlimited)
  -i include_pattern Only include files matching glob pattern
  -e exclude_pattern Exclude files matching glob pattern
  -s                 Skip sensitive files (.env, *.key, *.secret, *.pem, *.crt, *.p12, *.pfx)
  -f format          Output format: header|plain|json (default: header)
  -m max_size        Maximum file size (supports human-readable: 50MB, 10KB; default: 50MB)

Arguments:
  directory_path     Path to root directory (required)

Examples:
  $(basename "$0") /path/to/folder
  $(basename "$0") -d 2 -i '*.sh' -s /path/to/folder
  $(basename "$0") -f json -m 10MB /path/to/folder
EOF
}

# Convert human-readable sizes to bytes
convert_to_bytes() {
    local size="$1"
    if [[ "$size" =~ ^([0-9]+)([KkMmGg]?[Bb]?)?$ ]]; then
        local num="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[2]:-B}"
        case "${unit^^}" in
            B) echo "$num" ;;
            KB) echo $((num*1024)) ;;
            MB) echo $((num*1024*1024)) ;;
            GB) echo $((num*1024*1024*1024)) ;;
            *) echo "$num" ;;
        esac
    else
        echo "Error: Invalid size format '$size'" >&2
        exit 1
    fi
}

# Default Parameters
max_depth=""
include_pattern=""
exclude_pattern=""
skip_sensitive=false
output_format="header"
max_size=$((50*1024*1024)) # 50MB default
default_excluded_dirs=( ".git" "node_modules" "vendor" "venv" ".venv" )

sensitive_patterns=( ".env" "*.key" "*.secret" "*.pem" "*.crt" "*.p12" "*.pfx" )

# Parse Options
while getopts ":d:i:e:sf:m:h" opt; do
    case "$opt" in
        d)
            [[ "$OPTARG" =~ ^[0-9]+$ ]] || { echo "Error: -d requires non-negative integer"; exit 1; }
            max_depth="$OPTARG"
            ;;
        i) include_pattern="$OPTARG" ;;
        e) exclude_pattern="$OPTARG" ;;
        s) skip_sensitive=true ;;
        f)
            [[ "$OPTARG" =~ ^(plain|header|json)$ ]] || { echo "Error: -f must be plain|header|json"; exit 1; }
            output_format="$OPTARG"
            ;;
        m) max_size=$(convert_to_bytes "$OPTARG") ;;
        h|*) print_usage; exit 0 ;;
    esac
done
shift $((OPTIND-1))

# Validate directory argument
if [[ $# -ne 1 ]]; then
    echo "Error: Missing directory_path argument" >&2
    print_usage
    exit 1
fi

dir_path="$1"
[[ -d "$dir_path" ]] || { echo "Error: '$dir_path' is not a directory"; exit 2; }

# Build find command safely
find_args=( "$dir_path" )
[[ -n "$max_depth" ]] && find_args+=( -maxdepth "$max_depth" )
find_args+=( -type f )

# Include / exclude patterns
[[ -n "$include_pattern" ]] && find_args+=( -name "$include_pattern" )
[[ -n "$exclude_pattern" ]] && find_args+=( ! -name "$exclude_pattern" )

# Default excluded dirs
for d in "${default_excluded_dirs[@]}"; do
    find_args+=( ! -path "*/$d/*" )
done

# Walk files and output
find "${find_args[@]}" -print0 | while IFS= read -r -d '' file; do
    # Skip sensitive files
    if $skip_sensitive; then
        for pat in "${sensitive_patterns[@]}"; do
            [[ "$(basename "$file")" == "$pat" ]] && continue 2
        done
    fi

    # Skip large files
    filesize=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
    [[ "$filesize" -gt "$max_size" ]] && continue

    # Output formatting
    case "$output_format" in
        plain)
            cat "$file" || echo "[Error reading $file]" >&2
            ;;
        header)
            echo "===== File: $file ====="
            cat "$file" || echo "[Error reading $file]" >&2
            echo ""
            ;;
        json)
            content=$(cat "$file" 2>/dev/null || echo "[Error reading $file]")
            printf '{"file":"%s","size":%d,"content":"%s"}\n' "$file" "$filesize" "$content"
            ;;
    esac
done
