#!/usr/bin/env bash
#
# Dotfiles Management Script
# Modular, robust installer for terminal configurations
#
# Usage:
#   ./install.sh          # Interactive mode (default)
#   ./install.sh -y       # Automated mode (auto-backup and install)
#   ./install.sh -h       # Show help

set -euo pipefail

# =============================================================================
# CONFIGURATION & GLOBALS
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"
BACKUP_SUFFIX=".bak"
AUTO_MODE=false
FORCE_MODE=false
DRY_RUN=false

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Execution list - add new configuration functions here
INSTALL_FUNCTIONS=(
    "install_kitty"
    "install_zsh"
    "install_nvim"
)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

print_help() {
    cat <<EOF
Dotfiles Management Script

Usage: $(basename "$0") [OPTIONS]

Options:
    -y, --yes       Automated mode: backup existing configs and install without prompts
    -f, --force     Force mode: overwrite existing configs without backup (no prompts)
    -n, --dry-run   Show what would be done without making changes
    -h, --help      Show this help message

Examples:
    $(basename "$0")          # Interactive installation
    $(basename "$0") -y       # Non-interactive installation (with backup)
    $(basename "$0") -f       # Force overwrite (no backup, no prompts)
    $(basename "$0") -n       # Preview changes
EOF
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create backup of existing file/directory
backup_config() {
    local target="$1"
    local backup_name="${target}${BACKUP_SUFFIX}.$(date +%Y%m%d_%H%M%S)"

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY RUN] Would backup $target to $backup_name"
        else
            mv "$target" "$backup_name"
            log_success "Backed up $target to $backup_name"
        fi
        return 0
    fi
    return 1
}

# Prompt user for action when config exists
# Returns: 0=overwrite, 1=backup, 2=skip
prompt_config_action() {
    local config_name="$1"
    local target_path="$2"

    echo
    log_warn "Configuration '$config_name' already exists at: $target_path"
    echo "Choose an action:"
    echo "  [o] Overwrite - replace existing configuration"
    echo "  [b] Backup    - save existing as .bak and install new"
    echo "  [n] Skip      - keep existing configuration (default)"
    echo

    while true; do
        read -rp "Action [o/b/n]: " choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
        case "$choice" in
            o)
                echo
                log_warn "This will PERMANENTLY DELETE the existing configuration!"
                read -rp "Are you sure? Type 'yes' to confirm: " confirm
                if [[ "$confirm" == "yes" ]]; then
                    return 0
                else
                    log_info "Overwrite cancelled."
                fi
                ;;
            b)
                return 1
                ;;
            n|"")
                return 2
                ;;
            *)
                log_error "Invalid choice. Please enter o, b, or n."
                ;;
        esac
    done
}

# Handle existing configuration based on mode
# Returns: 0=proceed with install, 1=skip
handle_existing_config() {
    local config_name="$1"
    local target_path="$2"

    if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Config exists: $config_name at $target_path (would prompt in interactive mode)"
        return 0
    fi

    if [[ "$FORCE_MODE" == true ]]; then
        log_info "Force-mode: removing existing $config_name"
        rm -rf "$target_path"
        log_success "Removed existing $config_name"
        return 0
    fi

    if [[ "$AUTO_MODE" == true ]]; then
        log_info "Auto-mode: backing up existing $config_name"
        backup_config "$target_path"
        return 0
    fi

    local action
    prompt_config_action "$config_name" "$target_path"
    action=$?

    case $action in
        0)  # Overwrite
            rm -rf "$target_path"
            log_success "Removed existing $config_name"
            return 0
            ;;
        1)  # Backup
            backup_config "$target_path"
            return 0
            ;;
        2)  # Skip
            log_info "Skipping $config_name"
            return 1
            ;;
    esac
}

# Create symlink from dotfiles to target location
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        log_error "Source does not exist: $source"
        return 1
    fi

    local target_dir
    target_dir="$(dirname "$target")"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would create symlink: $target -> $source"
        return 0
    fi

    mkdir -p "$target_dir"
    ln -sfn "$source" "$target"
    log_success "Linked $target -> $source"
}

# =============================================================================
# CONFIGURATION INSTALL FUNCTIONS
# =============================================================================

install_kitty() {
    local config_name="Kitty"
    local source_dir="${DOTFILES_DIR}/kitty"
    local target_dir="${HOME}/.config/kitty"

    log_info "Installing $config_name configuration..."

    if [[ ! -d "$source_dir" ]]; then
        log_error "Source directory not found: $source_dir"
        return 1
    fi

    if ! handle_existing_config "$config_name" "$target_dir"; then
        return 0
    fi

    create_symlink "$source_dir" "$target_dir"
}

install_zsh() {
    local config_name="Zsh"
    local source_file="${DOTFILES_DIR}/zsh/.zshrc"
    local target_file="${HOME}/.zshrc"
    local source_zdir="${DOTFILES_DIR}/zsh/.zsh"
    local target_zdir="${HOME}/.zsh"

    log_info "Installing $config_name configuration..."

    if [[ ! -f "$source_file" ]]; then
        log_error "Source file not found: $source_file"
        return 1
    fi

    # Handle .zshrc
    if ! handle_existing_config "$config_name (.zshrc)" "$target_file"; then
        return 0
    fi
    create_symlink "$source_file" "$target_file"

    # Handle .zsh directory if it exists
    if [[ -d "$source_zdir" ]]; then
        if ! handle_existing_config "$config_name (.zsh dir)" "$target_zdir"; then
            return 0
        fi
        create_symlink "$source_zdir" "$target_zdir"
    fi
}

install_nvim() {
    local config_name="Neovim"
    local repo_url="https://github.com/Danielgpc/nvim-dotfiles.git"
    local target_dir="${HOME}/.config/nvim"
    local clone_dir="${DOTFILES_DIR}/nvim-config"

    log_info "Installing $config_name configuration..."

    # Handle existing nvim config
    if ! handle_existing_config "$config_name" "$target_dir"; then
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY RUN] Would clone $repo_url to $clone_dir"
        log_info "[DRY RUN] Would link $clone_dir to $target_dir"
        return 0
    fi

    # Clone or update the repository
    if [[ -d "$clone_dir" ]]; then
        log_info "Updating existing nvim-config repository..."
        git -C "$clone_dir" pull --ff-only
    else
        log_info "Cloning nvim-config repository..."
        git clone "$repo_url" "$clone_dir"
    fi

    # Create symlink to the cloned config
    create_symlink "$clone_dir" "$target_dir"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes)
                AUTO_MODE=true
                shift
                ;;
            -f|--force)
                FORCE_MODE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done
}

run_installers() {
    local failed=()

    log_info "Starting dotfiles installation..."
    [[ "$DRY_RUN" == true ]] && log_warn "DRY RUN MODE - No changes will be made"
    [[ "$AUTO_MODE" == true ]] && log_info "AUTO MODE - Non-interactive installation (with backup)"
    [[ "$FORCE_MODE" == true ]] && log_warn "FORCE MODE - Overwriting existing configs without backup"
    echo

    for func in "${INSTALL_FUNCTIONS[@]}"; do
        log_info "----------------------------------------"
        if ! "$func"; then
            failed+=("$func")
            log_error "Failed to install: $func"
        fi
    done

    echo
    log_info "----------------------------------------"
    if [[ ${#failed[@]} -eq 0 ]]; then
        log_success "All configurations installed successfully!"
    else
        log_error "Some configurations failed:"
        for f in "${failed[@]}"; do
            echo "  - $f"
        done
        exit 1
    fi
}

main() {
    parse_args "$@"
    run_installers
}

main "$@"