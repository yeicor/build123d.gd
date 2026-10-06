#!/usr/bin/env bash
# Download OpenCASCADE.gd addon binaries and web assets from the latest nightly build.
#
# Usage:
#   tools/download_addon.sh [OPTIONS]
#
# Options:
#   --triplet <triplet>     Target triplet (e.g. x64-linux, wasm32-emscripten, x64-windows-static, universal-osx)
#   --all                   Download GDExtension binaries for ALL supported platforms
#   --host                  Download GDExtension binary for current host (default)
#   --web-templates         Download custom Godot Web templates (debug + release)
#   --web-editor            Download custom Godot Web Editor
#   --dest <dir>            Destination for addon libraries (default: addons/OpenCASCADE.gd)
#   --run-id <id>           Specific workflow run ID (default: latest successful main run)
#   --help                  Show this help
#
# Examples:
#   tools/download_addon.sh
#   tools/download_addon.sh --triplet wasm32-emscripten --web-templates
#   tools/download_addon.sh --all

set -euo pipefail

REPO_OWNER="yeicor-gd"
REPO_NAME="OpenCASCADE.gd"
REPO="${REPO_OWNER}/${REPO_NAME}"
DEST="addons/OpenCASCADE.gd"
RUN_ID=""
DOWNLOAD_ALL=false
DOWNLOAD_HOST=false
DOWNLOAD_WEB_TEMPLATES=false
DOWNLOAD_WEB_EDITOR=false
TARGET_TRIPLET=""
TARGET_MODE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --triplet)
            TARGET_TRIPLET="$2"
            shift 2
            ;;
        --mode)
            TARGET_MODE="$2"
            shift 2
            ;;
        --all)
            DOWNLOAD_ALL=true
            shift
            ;;
        --host)
            DOWNLOAD_HOST=true
            shift
            ;;
        --web-templates)
            DOWNLOAD_WEB_TEMPLATES=true
            shift
            ;;
        --web-editor)
            DOWNLOAD_WEB_EDITOR=true
            shift
            ;;
        --dest)
            DEST="$2"
            shift 2
            ;;
        --run-id)
            RUN_ID="$2"
            shift 2
            ;;
        --help)
            sed -n '2,20p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# If nothing specified, default to host
if [ "$DOWNLOAD_ALL" = false ] && [ -z "$TARGET_TRIPLET" ] && [ "$DOWNLOAD_WEB_TEMPLATES" = false ] && [ "$DOWNLOAD_WEB_EDITOR" = false ]; then
    DOWNLOAD_HOST=true
fi

# Detect host triplet
detect_host_triplet() {
    local os arch
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    case "$os" in
        linux)
            case "$arch" in
                x86_64) echo "x64-linux" ;;
                i*86) echo "x86-linux" ;;
                aarch64|arm64) echo "arm64-linux" ;;
                arm*) echo "arm-linux" ;;
                *) echo "x64-linux" ;;
            esac
            ;;
        darwin)
            echo "universal-osx"
            ;;
        msys*|mingw*|cygwin*)
            case "$arch" in
                x86_64) echo "x64-windows-static" ;;
                i*86) echo "x86-windows-static" ;;
                aarch64|arm64) echo "arm64-windows-static" ;;
                *) echo "x64-windows-static" ;;
            esac
            ;;
        *)
            echo "x64-linux"
            ;;
    esac
}

if [ "$DOWNLOAD_HOST" = true ]; then
    TARGET_TRIPLET=$(detect_host_triplet)
    echo "Detected host triplet: $TARGET_TRIPLET"
fi

mkdir -p "$DEST"

# Resolve latest successful run ID
if [ -z "$RUN_ID" ]; then
    echo "Finding latest successful run of $REPO..."
    if command -v gh >/dev/null 2>&1; then
        for attempt in 1 2 3; do
            RUN_ID=$(gh run list --repo "$REPO" --workflow .github/workflows/main.yml --branch main --status success --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)
            if [ -n "$RUN_ID" ] && [ "$RUN_ID" != "null" ]; then
                break
            fi
            sleep 2
        done
        if [ -z "$RUN_ID" ] || [ "$RUN_ID" = "null" ]; then
            RUN_ID=$(gh run list --repo "$REPO" --workflow .github/workflows/main.yml --branch main --status success --limit 1 --json databaseId --jq '.[0].databaseId')
        fi
    else
        echo "Error: gh CLI is required but not installed." >&2
        exit 1
    fi
    if [ -z "$RUN_ID" ] || [ "$RUN_ID" = "null" ]; then
        echo "Error: Could not find latest successful run for $REPO" >&2
        exit 1
    fi
fi
echo "Using OpenCASCADE.gd run ID: $RUN_ID"

# Helper to download artifact with gh CLI
download_and_extract_artifact() {
    local pattern="$1"
    local target_dir="$2"
    local tmp
    tmp=$(mktemp -d)

    local downloaded=false
    if command -v gh >/dev/null 2>&1; then
        for attempt in 1 2 3; do
            if gh run download "$RUN_ID" --repo "$REPO" --pattern "$pattern" --dir "$tmp" 2>/dev/null; then
                downloaded=true
                break
            fi
            sleep 2
        done
        if [ "$downloaded" = false ]; then
            if gh run download "$RUN_ID" --repo "$REPO" --pattern "$pattern" --dir "$tmp"; then
                downloaded=true
            fi
        fi
    fi

    if [ "$downloaded" = true ]; then
        mkdir -p "$target_dir"
        # Find any libraries or target files and copy
        for f in $(find "$tmp" -type f \( -name "*.so" -o -name "*.dll" -o -name "*.dylib" -o -name "*.a" -o -name "*.zip" \)); do
            cp -f "$f" "$target_dir/"
        done
        echo "  Installed files from $pattern to $target_dir"
        rm -rf "$tmp"
        return 0
    else
        echo "Error: Could not download artifact matching pattern: $pattern" >&2
        rm -rf "$tmp"
        return 1
    fi
}

# Download libraries
if [ "$DOWNLOAD_ALL" = true ]; then
    echo "Downloading all platform binaries..."
    download_and_extract_artifact "gdext-*" "$DEST"
elif [ -n "$TARGET_TRIPLET" ]; then
    if [ -n "$TARGET_MODE" ]; then
        echo "Downloading binaries for triplet: $TARGET_TRIPLET ($TARGET_MODE single-precision)..."
        if ! download_and_extract_artifact "gdext-${TARGET_TRIPLET}-template_${TARGET_MODE}-single-*" "$DEST"; then
            echo "Falling back to all artifacts for triplet: $TARGET_TRIPLET..."
            download_and_extract_artifact "gdext-${TARGET_TRIPLET}-*" "$DEST"
        fi
    else
        echo "Downloading binaries for triplet: $TARGET_TRIPLET..."
        download_and_extract_artifact "gdext-${TARGET_TRIPLET}-*" "$DEST"
    fi
fi

# Download custom web templates if requested
if [ "$DOWNLOAD_WEB_TEMPLATES" = true ]; then
    echo "Downloading custom Godot Web templates..."
    mkdir -p templates/threads
    tmp_tpl=$(mktemp -d)
    if command -v gh >/dev/null 2>&1; then
        gh run download "$RUN_ID" --repo "$REPO" --name "web-template-release" --dir "$tmp_tpl/rel" 2>/dev/null || true
        gh run download "$RUN_ID" --repo "$REPO" --name "web-template-debug" --dir "$tmp_tpl/dbg" 2>/dev/null || true
        if [ -f "$tmp_tpl/rel/threads/web_release.zip" ]; then
            cp "$tmp_tpl/rel/threads/web_release.zip" templates/threads/
            echo "  Installed templates/threads/web_release.zip"
        fi
        if [ -f "$tmp_tpl/dbg/threads/web_debug.zip" ]; then
            cp "$tmp_tpl/dbg/threads/web_debug.zip" templates/threads/
            echo "  Installed templates/threads/web_debug.zip"
        fi
    fi
    rm -rf "$tmp_tpl"
fi

# Download custom web editor if requested
if [ "$DOWNLOAD_WEB_EDITOR" = true ]; then
    echo "Downloading custom Godot Web Editor..."
    mkdir -p web/editor
    tmp_ed=$(mktemp -d)
    if command -v gh >/dev/null 2>&1; then
        gh run download "$RUN_ID" --repo "$REPO" --name "web-editor-release" --dir "$tmp_ed" 2>/dev/null || true
        if [ -f "$tmp_ed/editor/threads/web_editor_release.zip" ]; then
            unzip -q -o "$tmp_ed/editor/threads/web_editor_release.zip" -d web/editor/
            echo "  Extracted web editor to web/editor/"
        fi
    fi
    rm -rf "$tmp_ed"
fi

echo "Done! Addon status:"
ls -lh "$DEST"
