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

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FRAMEWORK_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

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

# Validate target directory
if [ ! -d "$TARGET_DIR" ]; then
    print_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Detect project name from directory (used for config files)
PROJECT_NAME="$(basename "$TARGET_DIR")"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Agentic Framework - Initialization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_info "Framework source: $FRAMEWORK_DIR"
print_info "Target directory: $TARGET_DIR"
print_info "Project name: $PROJECT_NAME"
echo ""

# Check if .claude directory already exists
OVERWRITE_CLAUDE=false
if [ -d "$TARGET_DIR/.claude" ]; then
    print_warning ".claude directory already exists in target"
    if confirm "  Overwrite existing .claude directory?"; then
        OVERWRITE_CLAUDE=true
        print_info "Will overwrite .claude directory"
    else
        print_info "Skipping .claude directory"
    fi
    echo ""
fi

# Copy .claude directory
if [ "$OVERWRITE_CLAUDE" = true ] || [ ! -d "$TARGET_DIR/.claude" ]; then
    print_info "Copying .claude directory..."

    # Remove existing if overwriting
    if [ "$OVERWRITE_CLAUDE" = true ]; then
        rm -rf "$TARGET_DIR/.claude"
    fi

    cp -r "$FRAMEWORK_DIR/.claude" "$TARGET_DIR/.claude"
    print_success ".claude directory installed"
else
    print_info "Skipped .claude directory (already exists)"
fi

# Check if .devcontainer directory already exists
OVERWRITE_DEVCONTAINER=false
if [ -d "$TARGET_DIR/.devcontainer" ]; then
    print_warning ".devcontainer directory already exists in target"
    if confirm "  Overwrite existing .devcontainer directory?"; then
        OVERWRITE_DEVCONTAINER=true
        print_info "Will overwrite .devcontainer directory"
    else
        print_info "Skipping .devcontainer directory"
    fi
    echo ""
fi

# Copy .devcontainer directory
if [ "$OVERWRITE_DEVCONTAINER" = true ] || [ ! -d "$TARGET_DIR/.devcontainer" ]; then
    print_info "Copying .devcontainer directory..."

    # Remove existing if overwriting
    if [ "$OVERWRITE_DEVCONTAINER" = true ]; then
        rm -rf "$TARGET_DIR/.devcontainer"
    fi

    cp -r "$FRAMEWORK_DIR/.devcontainer" "$TARGET_DIR/.devcontainer"
    print_success ".devcontainer directory installed"
else
    print_info "Skipped .devcontainer directory (already exists)"
fi

# Copy templates directory
if [ -d "$TARGET_DIR/templates" ]; then
    print_warning "templates directory already exists"
    if confirm "  Overwrite existing templates directory?"; then
        rm -rf "$TARGET_DIR/templates"
        cp -r "$FRAMEWORK_DIR/templates" "$TARGET_DIR/templates"
        print_success "templates directory updated"
    else
        print_info "Skipped templates directory"
    fi
else
    print_info "Copying templates directory..."
    cp -r "$FRAMEWORK_DIR/templates" "$TARGET_DIR/templates"
    print_success "templates directory installed"
fi

# Create artifacts directory if it doesn't exist
if [ ! -d "$TARGET_DIR/artifacts" ]; then
    print_info "Creating artifacts directory..."
    mkdir -p "$TARGET_DIR/artifacts"
    print_success "artifacts directory created"
else
    print_info "artifacts directory already exists"
fi

# Copy .gitattributes if it doesn't exist
if [ ! -f "$TARGET_DIR/.gitattributes" ]; then
    print_info "Copying .gitattributes..."
    cp "$FRAMEWORK_DIR/.gitattributes" "$TARGET_DIR/.gitattributes"
    print_success ".gitattributes installed"
else
    print_info ".gitattributes already exists (not overwriting)"
fi

# Copy .mcp.json if it doesn't exist
if [ ! -f "$TARGET_DIR/.mcp.json" ]; then
    print_info "Copying .mcp.json (MCP server configuration)..."
    cp "$FRAMEWORK_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"
    print_success ".mcp.json installed"
else
    print_info ".mcp.json already exists (not overwriting)"
fi

# Copy .beads configuration template (optional)
if [ -d "$FRAMEWORK_DIR/.beads" ]; then
    if [ ! -d "$TARGET_DIR/.beads" ]; then
        print_warning ".beads directory not found"
        if confirm "  Copy Beads configuration template?"; then
            mkdir -p "$TARGET_DIR/.beads"
            # Only copy template files, not runtime state
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
        print_info ".beads directory already exists (not overwriting)"
    fi
fi

# Copy .serena configuration template (optional)
if [ -d "$FRAMEWORK_DIR/.serena" ]; then
    if [ ! -d "$TARGET_DIR/.serena" ]; then
        print_warning ".serena directory not found"
        if confirm "  Copy Serena MCP server configuration template?"; then
            mkdir -p "$TARGET_DIR/.serena"
            if [ -f "$FRAMEWORK_DIR/.serena/project.yml" ]; then
                cp "$FRAMEWORK_DIR/.serena/project.yml" "$TARGET_DIR/.serena/"
                # Update project_name to match target directory
                if command -v sed &> /dev/null; then
                    sed -i.bak "s/^project_name:.*/project_name: \"$PROJECT_NAME\"/" "$TARGET_DIR/.serena/project.yml"
                    rm -f "$TARGET_DIR/.serena/project.yml.bak"
                fi
            fi
            print_success ".serena configuration installed (project_name: $PROJECT_NAME)"
        else
            print_info "Skipped .serena configuration"
        fi
        echo ""
    else
        print_info ".serena directory already exists (not overwriting)"
    fi
fi

# Create CLAUDE.md from template if it doesn't exist
if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    print_info "Creating CLAUDE.md..."
    cp "$FRAMEWORK_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    print_success "CLAUDE.md created (customize this for your project!)"
else
    print_info "CLAUDE.md already exists (not overwriting)"
fi

# Create README.md from template if it doesn't exist
if [ ! -f "$TARGET_DIR/README.md" ]; then
    print_warning "README.md does not exist"
    if confirm "  Create README.md from framework template?"; then
        cp "$FRAMEWORK_DIR/README.md" "$TARGET_DIR/README.md"
        print_success "README.md created"
    else
        print_info "Skipped README.md"
    fi
else
    print_info "README.md already exists (not overwriting)"
fi

# Create .gitignore if it doesn't exist
if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    print_warning ".gitignore does not exist"
    if confirm "  Create basic .gitignore?"; then
        cat > "$TARGET_DIR/.gitignore" << 'EOF'
# Dependencies
node_modules/
.pnpm-store/
__pycache__/
*.pyc
.venv/
venv/

# Build outputs
dist/
build/
*.o
*.so
*.exe

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
*.local

# Logs
*.log
npm-debug.log*
EOF
        print_success ".gitignore created"
    else
        print_info "Skipped .gitignore"
    fi
else
    print_info ".gitignore already exists (not overwriting)"
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
