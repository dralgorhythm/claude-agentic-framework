#!/bin/bash
# Claude Agentic Framework - Initialization Script
# Usage: ./init-framework.sh [/path/to/your/project]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository URL for cloning when run via curl
REPO_URL="https://github.com/dralgorhythm/claude-agentic-framework.git"

# Determine framework source directory
# When run via curl | bash, BASH_SOURCE[0] is not a valid file path
if [ -f "${BASH_SOURCE[0]}" ]; then
    # Running from local file
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    FRAMEWORK_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
    TEMP_CLONE=""
else
    # Running via curl | bash - need to clone the repo
    echo "Downloading framework from repository..."
    TEMP_CLONE="$(mktemp -d)"
    git clone --depth 1 --quiet "$REPO_URL" "$TEMP_CLONE"
    FRAMEWORK_DIR="$TEMP_CLONE"
fi

# Cleanup function for temp directory
cleanup() {
    if [ -n "$TEMP_CLONE" ] && [ -d "$TEMP_CLONE" ]; then
        rm -rf "$TEMP_CLONE"
    fi
}
trap cleanup EXIT

# Target directory (default: current directory)
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Function to prompt user for confirmation
confirm() {
    local prompt="$1"
    local response
    read -r -p "$prompt [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to show diff between two files
show_file_diff() {
    local existing="$1"
    local new="$2"
    local name="$3"

    if command -v diff &>/dev/null; then
        echo ""
        echo -e "${BLUE}--- Diff for ${name} ---${NC}"
        # Use color diff if available, otherwise plain diff
        if diff --color=auto /dev/null /dev/null 2>/dev/null; then
            diff --color=auto -u "$existing" "$new" 2>/dev/null || true
        else
            diff -u "$existing" "$new" 2>/dev/null || true
        fi
        echo -e "${BLUE}--- End diff ---${NC}"
        echo ""
    fi
}

# Function to show diff summary for directories
show_dir_diff() {
    local existing="$1"
    local new="$2"
    local name="$3"

    if command -v diff &>/dev/null; then
        echo ""
        echo -e "${BLUE}--- Changes in ${name}/ ---${NC}"

        # Show new files
        local new_files
        new_files=$(diff -rq "$existing" "$new" 2>/dev/null | grep "Only in $new" | sed "s|Only in $new[^:]*: |  + |" || true)
        if [ -n "$new_files" ]; then
            echo -e "${GREEN}New files:${NC}"
            echo "$new_files"
        fi

        # Show removed files
        local removed_files
        removed_files=$(diff -rq "$existing" "$new" 2>/dev/null | grep "Only in $existing" | sed "s|Only in $existing[^:]*: |  - |" || true)
        if [ -n "$removed_files" ]; then
            echo -e "${RED}Files only in existing:${NC}"
            echo "$removed_files"
        fi

        # Show modified files
        local modified_files
        modified_files=$(diff -rq "$existing" "$new" 2>/dev/null | grep "^Files .* differ$" | sed -E 's/Files (.*) and .* differ/  ~ \1/' || true)
        if [ -n "$modified_files" ]; then
            echo -e "${YELLOW}Modified files:${NC}"
            echo "$modified_files"
        fi

        # Count changes
        local total_changes
        total_changes=$(diff -rq "$existing" "$new" 2>/dev/null | wc -l | tr -d ' ')
        echo ""
        echo "Total: $total_changes file(s) differ"
        echo -e "${BLUE}--- End summary ---${NC}"
        echo ""
    fi
}

# Function to copy file with diff prompt
copy_file_with_diff() {
    local src="$1"
    local dst="$2"
    local name="$3"
    local optional="${4:-false}"

    if [ ! -f "$src" ]; then
        if [ "$optional" = "true" ]; then
            return 0
        fi
        print_error "Source file not found: $src"
        return 1
    fi

    if [ -f "$dst" ]; then
        # Check if files are identical
        if diff -q "$dst" "$src" &>/dev/null; then
            print_info "$name is already up to date"
            return 0
        fi

        print_warning "$name already exists with differences"
        show_file_diff "$dst" "$src" "$name"

        if confirm "  Overwrite $name?"; then
            cp "$src" "$dst"
            print_success "$name updated"
        else
            print_info "Skipped $name"
        fi
    else
        print_info "Copying $name..."
        cp "$src" "$dst"
        print_success "$name installed"
    fi
}

# Function to copy directory with diff prompt
copy_dir_with_diff() {
    local src="$1"
    local dst="$2"
    local name="$3"
    local optional="${4:-false}"

    if [ ! -d "$src" ]; then
        if [ "$optional" = "true" ]; then
            return 0
        fi
        print_error "Source directory not found: $src"
        return 1
    fi

    if [ -d "$dst" ]; then
        # Check if directories are identical
        if diff -rq "$dst" "$src" &>/dev/null; then
            print_info "$name/ is already up to date"
            return 0
        fi

        print_warning "$name/ already exists with differences"
        show_dir_diff "$dst" "$src" "$name"

        if confirm "  Overwrite $name/?"; then
            rm -rf "$dst"
            cp -r "$src" "$dst"
            print_success "$name/ updated"
        else
            print_info "Skipped $name/"
        fi
    else
        print_info "Copying $name/..."
        cp -r "$src" "$dst"
        print_success "$name/ installed"
    fi
}

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Detect project name (prefer GitHub repo name, fallback to directory name)
detect_project_name() {
    local dir="$1"

    # Try to get GitHub repo name from git remote
    if [ -d "$dir/.git" ] || git -C "$dir" rev-parse --git-dir &>/dev/null; then
        local remote_url
        remote_url=$(git -C "$dir" remote get-url origin 2>/dev/null || echo "")

        if [ -n "$remote_url" ]; then
            # Extract repo name from various URL formats:
            # https://github.com/user/repo.git -> repo
            # git@github.com:user/repo.git -> repo
            # https://github.com/user/repo -> repo
            local repo_name
            repo_name=$(echo "$remote_url" | sed -E 's#.*/([^/]+)(\.git)?$#\1#' | sed 's/\.git$//')

            if [ -n "$repo_name" ]; then
                echo "$repo_name"
                return
            fi
        fi
    fi

    # Fallback to directory name
    basename "$dir"
}

PROJECT_NAME="$(detect_project_name "$TARGET_DIR")"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Agentic Framework - Initialization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_info "Framework source: $FRAMEWORK_DIR"
print_info "Target directory: $TARGET_DIR"
print_info "Project name: $PROJECT_NAME"
echo ""

# Copy core directories with diff support
copy_dir_with_diff "$FRAMEWORK_DIR/.claude" "$TARGET_DIR/.claude" ".claude"
copy_dir_with_diff "$FRAMEWORK_DIR/.devcontainer" "$TARGET_DIR/.devcontainer" ".devcontainer"
copy_dir_with_diff "$FRAMEWORK_DIR/templates" "$TARGET_DIR/templates" "templates"

# Create artifacts directory if it doesn't exist
if [ ! -d "$TARGET_DIR/artifacts" ]; then
    print_info "Creating artifacts directory..."
    mkdir -p "$TARGET_DIR/artifacts"
    print_success "artifacts directory created"
else
    print_info "artifacts directory already exists"
fi

# Copy config files with diff support
copy_file_with_diff "$FRAMEWORK_DIR/.gitattributes" "$TARGET_DIR/.gitattributes" ".gitattributes"
copy_file_with_diff "$FRAMEWORK_DIR/.mcp.json" "$TARGET_DIR/.mcp.json" ".mcp.json"

# Copy .beads configuration template (optional) with diff support
if [ -d "$FRAMEWORK_DIR/.beads" ]; then
    if [ ! -d "$TARGET_DIR/.beads" ]; then
        print_warning ".beads directory not found"
        if confirm "  Copy Beads configuration template?"; then
            mkdir -p "$TARGET_DIR/.beads"
            [ -f "$FRAMEWORK_DIR/.beads/config.yaml" ] && cp "$FRAMEWORK_DIR/.beads/config.yaml" "$TARGET_DIR/.beads/"
            [ -f "$FRAMEWORK_DIR/.beads/README.md" ] && cp "$FRAMEWORK_DIR/.beads/README.md" "$TARGET_DIR/.beads/"
            [ -f "$FRAMEWORK_DIR/.beads/.gitignore" ] && cp "$FRAMEWORK_DIR/.beads/.gitignore" "$TARGET_DIR/.beads/"
            print_success ".beads configuration template installed"
            print_info "  Run 'bd init' to initialize Beads issue tracking"
        else
            print_info "Skipped .beads configuration"
        fi
        echo ""
    else
        # Show diff for existing .beads directory
        if ! diff -rq "$TARGET_DIR/.beads" "$FRAMEWORK_DIR/.beads" &>/dev/null; then
            print_warning ".beads/ already exists with differences"
            show_dir_diff "$TARGET_DIR/.beads" "$FRAMEWORK_DIR/.beads" ".beads"
            if confirm "  Update .beads configuration?"; then
                [ -f "$FRAMEWORK_DIR/.beads/config.yaml" ] && cp "$FRAMEWORK_DIR/.beads/config.yaml" "$TARGET_DIR/.beads/"
                [ -f "$FRAMEWORK_DIR/.beads/README.md" ] && cp "$FRAMEWORK_DIR/.beads/README.md" "$TARGET_DIR/.beads/"
                [ -f "$FRAMEWORK_DIR/.beads/.gitignore" ] && cp "$FRAMEWORK_DIR/.beads/.gitignore" "$TARGET_DIR/.beads/"
                print_success ".beads configuration updated"
            else
                print_info "Skipped .beads/"
            fi
        else
            print_info ".beads/ is already up to date"
        fi
    fi
fi

# Copy .serena configuration template (optional) with diff support
if [ -d "$FRAMEWORK_DIR/.serena" ]; then
    # Create temp version with updated project name for comparison
    SERENA_TEMP=""
    if [ -f "$FRAMEWORK_DIR/.serena/project.yml" ]; then
        SERENA_TEMP="$(mktemp -d)"
        cp -r "$FRAMEWORK_DIR/.serena"/* "$SERENA_TEMP/" 2>/dev/null || true
        if command -v sed &>/dev/null; then
            sed -i.bak "s/^project_name:.*/project_name: \"$PROJECT_NAME\"/" "$SERENA_TEMP/project.yml"
            rm -f "$SERENA_TEMP/project.yml.bak"
        fi
    fi

    if [ ! -d "$TARGET_DIR/.serena" ]; then
        print_warning ".serena directory not found"
        if confirm "  Copy Serena MCP server configuration template?"; then
            mkdir -p "$TARGET_DIR/.serena"
            if [ -n "$SERENA_TEMP" ]; then
                cp -r "$SERENA_TEMP"/* "$TARGET_DIR/.serena/"
            fi
            print_success ".serena configuration installed (project_name: $PROJECT_NAME)"
        else
            print_info "Skipped .serena configuration"
        fi
        echo ""
    else
        # Show diff for existing .serena directory
        if [ -n "$SERENA_TEMP" ] && ! diff -rq "$TARGET_DIR/.serena" "$SERENA_TEMP" &>/dev/null; then
            print_warning ".serena/ already exists with differences"
            show_dir_diff "$TARGET_DIR/.serena" "$SERENA_TEMP" ".serena"
            if confirm "  Update .serena configuration?"; then
                cp -r "$SERENA_TEMP"/* "$TARGET_DIR/.serena/"
                print_success ".serena configuration updated (project_name: $PROJECT_NAME)"
            else
                print_info "Skipped .serena/"
            fi
        else
            print_info ".serena/ is already up to date"
        fi
    fi

    # Cleanup temp
    [ -n "$SERENA_TEMP" ] && rm -rf "$SERENA_TEMP"
fi

# Copy CLAUDE.md with diff support
copy_file_with_diff "$FRAMEWORK_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md"

# Copy README.md with diff support (optional for existing projects)
if [ ! -f "$TARGET_DIR/README.md" ]; then
    print_warning "README.md does not exist"
    if confirm "  Create README.md from framework template?"; then
        cp "$FRAMEWORK_DIR/README.md" "$TARGET_DIR/README.md"
        print_success "README.md created"
    else
        print_info "Skipped README.md"
    fi
else
    # Only show diff for README if user wants to see framework updates
    if ! diff -q "$TARGET_DIR/README.md" "$FRAMEWORK_DIR/README.md" &>/dev/null; then
        print_info "README.md exists (differs from framework template)"
        if confirm "  View diff and optionally update?"; then
            show_file_diff "$TARGET_DIR/README.md" "$FRAMEWORK_DIR/README.md" "README.md"
            if confirm "  Overwrite README.md with framework template?"; then
                cp "$FRAMEWORK_DIR/README.md" "$TARGET_DIR/README.md"
                print_success "README.md updated"
            else
                print_info "Kept existing README.md"
            fi
        else
            print_info "Skipped README.md"
        fi
    else
        print_info "README.md is already up to date"
    fi
fi

# Create or update .gitignore (append mode for existing files)
GITIGNORE_ENTRIES=(
    "# Dependencies"
    "node_modules/"
    ".pnpm-store/"
    "__pycache__/"
    "*.pyc"
    ".venv/"
    "venv/"
    "# Build outputs"
    "dist/"
    "build/"
    "*.o"
    "*.so"
    "*.exe"
    "# IDE"
    ".vscode/"
    ".idea/"
    "*.swp"
    "*.swo"
    "*~"
    "# OS"
    ".DS_Store"
    "Thumbs.db"
    "# Environment"
    ".env"
    ".env.local"
    "*.local"
    "# Logs"
    "*.log"
    "npm-debug.log*"
)

if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    print_warning ".gitignore does not exist"
    if confirm "  Create basic .gitignore?"; then
        printf '%s\n' "${GITIGNORE_ENTRIES[@]}" > "$TARGET_DIR/.gitignore"
        print_success ".gitignore created"
    else
        print_info "Skipped .gitignore"
    fi
else
    # Find missing entries (excluding comments)
    MISSING_ENTRIES=()
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        # Skip comment lines for matching
        if [[ "$entry" == \#* ]]; then
            continue
        fi
        # Check if entry exists in current .gitignore (exact line match)
        if ! grep -Fxq "$entry" "$TARGET_DIR/.gitignore" 2>/dev/null; then
            MISSING_ENTRIES+=("$entry")
        fi
    done

    if [ ${#MISSING_ENTRIES[@]} -eq 0 ]; then
        print_info ".gitignore already contains all framework entries"
    else
        print_warning ".gitignore is missing ${#MISSING_ENTRIES[@]} framework entries"
        echo ""
        echo -e "${BLUE}--- Entries to append ---${NC}"
        for entry in "${MISSING_ENTRIES[@]}"; do
            echo -e "${GREEN}  + $entry${NC}"
        done
        echo -e "${BLUE}--- End entries ---${NC}"
        echo ""

        if confirm "  Append missing entries to .gitignore?"; then
            # Add a blank line separator if file doesn't end with newline
            if [ -s "$TARGET_DIR/.gitignore" ] && [ "$(tail -c1 "$TARGET_DIR/.gitignore" | wc -l)" -eq 0 ]; then
                echo "" >> "$TARGET_DIR/.gitignore"
            fi
            # Add framework section header
            echo "" >> "$TARGET_DIR/.gitignore"
            echo "# Claude Agentic Framework" >> "$TARGET_DIR/.gitignore"
            for entry in "${MISSING_ENTRIES[@]}"; do
                echo "$entry" >> "$TARGET_DIR/.gitignore"
            done
            print_success ".gitignore updated (${#MISSING_ENTRIES[@]} entries appended)"
        else
            print_info "Kept existing .gitignore"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "Framework initialization complete!"
echo ""

# Install hook dependencies if needed
if [ -f "$TARGET_DIR/.claude/hooks/package.json" ]; then
    print_info "Installing hook dependencies..."
    echo ""
    cd "$TARGET_DIR/.claude/hooks"

    if command -v pnpm &> /dev/null; then
        pnpm install --silent
    elif command -v npm &> /dev/null; then
        npm install --silent
    else
        print_warning "Neither pnpm nor npm found - skipping dependency installation"
        print_info "Install Node.js and run: cd .claude/hooks && npm install"
    fi

    if [ $? -eq 0 ]; then
        print_success "Hook dependencies installed"
    fi

    cd - > /dev/null
    echo ""
fi

# Print next steps
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Customize CLAUDE.md with your project-specific context"
echo ""
echo "2. Review tech strategy in .claude/rules/tech-strategy.md"
echo "   Update to match your organization's standards"
echo ""
echo "3. Start using personas via slash commands:"
echo "   /architect    - System design and ADRs"
echo "   /builder      - Code implementation"
echo "   /product-manager - PRDs and requirements"
echo ""
echo "4. Optional: Install Beads for AI-native issue tracking:"
echo "   curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash"
echo "   cd $TARGET_DIR && bd init"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
