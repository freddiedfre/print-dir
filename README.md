# Print Dir

**print-dir** is a cross-platform CLI utility for recursively printing directory contents with advanced filtering, formatting, and file handling options. It is designed for developers and DevOps engineers to inspect file hierarchies safely and efficiently.

---

## Features

- Recursively prints files from a directory hierarchy.
- Supports **maximum recursion depth**.
- Filter files using **include** and **exclude** patterns.
- Exclude sensitive files (e.g., `.env`, `.key`, `.secret`, `.pem`, `.crt`, `.p12`, `.pfx`, `.jks`).
- Skip default heavy or generated directories (`.git`, `node_modules`, `vendor`, Python virtual environments, `.venv`).
- Limit output to files smaller than a **max size** (supports human-friendly sizes: B, KB, MB, GB; default: 10MB).
- Supports multiple **output formats**: `header` (default), `plain`, `json`.
- Cross-platform: Linux, macOS, Windows (with Bash / Git Bash / WSL).
- Well-formatted output with clear file path labeling.
- Interactive and automated-friendly modes.

---

## Installation

Download and install the latest release without cloning:

### Install via curl

```bash
VERSION=v0.4.0
OS=$(uname | tr '[:upper:]' '[:lower:]')
curl -L https://github.com/freddiedfre/print-dir/releases/latest/download/print-dir-${VERSION}-${OS}-amd64.tar.gz | tar xz
sudo mv print-dir /usr/local/bin/

```

### From Git Repository

```bash
git clone https://github.com/freddiedfre/print-dir.git
cd print-dir
chmod +x bin/print-dir scripts/print-dir.sh
```

### Option 1: Add to PATH (recommended for user-level use)

```bash
export PATH="$PWD/bin:$PATH"
# Optionally, add this line to ~/.bashrc or ~/.zshrc
```

### Option 2: Install system-wide via Make

```bash
sudo make install    # Install globally
sudo make uninstall  # Remove installation
```

---

## Usage

```bash
print-dir [-d max_depth] [-i include_pattern] [-e exclude_pattern] [-s] [-f format] [-m max_size] directory_path
```

### Options

| Option               | Description                                                            |
| -------------------- | ---------------------------------------------------------------------- |
| `-d max_depth`       | Maximum recursion depth (default: unlimited)                           |
| `-i include_pattern` | Only include files matching glob pattern (e.g., `*.txt`)               |
| `-e exclude_pattern` | Exclude files matching glob pattern (e.g., `*.log`)                    |
| `-s`                 | Skip sensitive files (`.env`, `.key`, `.secret`, `.pem`, `.crt`, etc.) |
| `-f format`          | Output format: `header` (default), `plain`, `json`                     |
| `-m max_size`        | Maximum file size to include (supports B, KB, MB, GB; default: 10MB)   |

### Examples

Print all files in a directory (default behavior):

```bash
print-dir /path/to/project
```

Print only `.sh` files, excluding `.log` files, with max depth 3:

```bash
print-dir -d 3 -i '*.sh' -e '*.log' /path/to/project
```

Print files in JSON format, skipping sensitive files:

```bash
print-dir -s -f json /path/to/project
```

Limit output to files smaller than 5MB:

```bash
print-dir -m 5MB /path/to/project
```

---

## Default Exclusions

- Directories: `.git`, `node_modules`, `vendor`, `.venv`, `venv`, `env`
- Sensitive files: `.env`, `*.key`, `*.secret`, `.pem`, `.crt`, `.p12`, `.pfx`, `.jks`

---

## Development & CI

- **Linting:** `make lint` uses `shellcheck` to enforce shell best practices.
- **Tests:** `make test` runs Bats tests in `tests/test_print_dir.bats`.
- **Build:** `make build` copies scripts to `bin/` and ensures executables.
- Cross-platform CI tested on Ubuntu, macOS, and Windows.

---

## Contribution

Use **Conventional Commits** and ensure tests pass before submitting PRs.

---

## License

[MIT](./LICENSE)

---
