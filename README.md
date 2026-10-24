# Terminal Dotfiles

Modular dotfiles management script for organizing, backing up, and installing terminal configurations.

## Quick Start

```bash
# Preview what would happen (no changes)
./install.sh -n

# Interactive installation (prompts for each config)
./install.sh

# Automated installation (backup & install without prompts)
./install.sh -y
```

## Features

- **Modular Architecture** - Each configuration is a separate function
- **Interactive Mode** - Choose to overwrite, backup, or skip existing configs
- **Automated Mode (`-y`)** - Non-interactive, auto-backups existing files
- **Dry Run (`-n`)** - Preview changes without making them
- **Safe Backups** - Timestamped `.bak` files before overwriting

## Included Configurations

| Config | Source | Target |
|--------|--------|--------|
| Kitty | `dotfiles/kitty/` | `~/.config/kitty/` |
| Zsh | `dotfiles/zsh/.zshrc` + `dotfiles/zsh/.zsh/` | `~/.zshrc` + `~/.zsh/` |
| Neovim | Cloned from GitHub | `~/.config/nvim/` |

## Adding New Configurations

1. **Create the configuration files** in `dotfiles/<name>/`

2. **Add an install function** in `install.sh`:

```bash
install_mytool() {
    local config_name="MyTool"
    local source_dir="${DOTFILES_DIR}/mytool"
    local target_dir="${HOME}/.config/mytool"

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
```

3. **Register the function** in the `INSTALL_FUNCTIONS` array:

```bash
INSTALL_FUNCTIONS=(
    "install_kitty"
    "install_zsh"
    "install_nvim"
    "install_mytool"   # Add here
)
```

That's it! The script will automatically handle prompting, backups, and symlinking.

## Configuration Structure

```
terminal-dotfiles/
├── install.sh              # Main installation script
├── dotfiles/               # Configuration sources
│   ├── kitty/
│   │   ├── kitty.conf
│   │   └── catppuccin-mocha.conf
│   ├── zsh/
│   │   ├── .zshrc
│   │   └── .zsh/
│   │       └── custom.zsh
│   └── mytool/             # Add new configs here
└── README.md
```

## Neovim Configuration

The Neovim config is cloned from a separate repository. Update the `repo_url` in `install_nvim()`:

```bash
local repo_url="https://github.com/YOUR_USERNAME/nvim-config.git"
```

## Requirements

- Bash 3.2+ (macOS default works)
- Git (for Neovim config)
- GNU coreutils (for `date` command)

## License

MIT