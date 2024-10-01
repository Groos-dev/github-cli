#!/bin/bash
# Define the base URL for the raw GitHub content
BASE_URL="https://raw.githubusercontent.com/Groos-dev/github-cli/refs/heads/main/gh_cli.sh"

CORE_FILE="$HOME/.gh-cli/bin/gh_cli.sh"
if [ -f "$CORE_FILE" ]; then
    echo "gh-cli is already installed"
    exit 0
fi

curl -sSL "$BASE_URL" -o "$CORE_FILE"
chmod +x "$CORE_FILE"
# shell config
shell_config="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    shell_config="$HOME/.zshrc"
fi

# Check if the PATH is already updated
if ! grep -q 'export PATH="$HOME/.gh-cli/bin:$PATH"' "$shell_config"; then
    echo 'export PATH="$HOME/.gh-cli/bin:$PATH"' >>"$shell_config"
    echo "PATH has been updated in $shell_config"
else
    echo "PATH already contains ~/.gh-cli/bin"
fi
# Add alias for gh-cli
echo "alias gh-cli='source $HOME/.gh-cli/bin/gh_cli.sh'" >>"$shell_config"
echo "Alias for gh-cli has been added to $shell_config"

# Reload the shell configuration
# source "$shell_config"

echo "gh-cli has been installed successfully. Please restart your terminal or run 'source $shell_config' to use gh-cli."
