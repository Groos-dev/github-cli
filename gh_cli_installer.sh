#!/bin/bash
# Define the base URL for the raw GitHub content
BASE_URL="https://raw.githubusercontent.com/Groos-dev/github-cli/refs/heads/main/gh_cli.sh"

CORE_FILE="$HOME/.gh-cli/bin/gh-cli"
if [ -f "$CORE_FILE" ]; then
    echo "gh-cli is already installed"
    exit 0
fi

Download the gh_cli.sh file
download_result=$(curl -sSL "$BASE_URL" -o "$CORE_FILE" 2>&1)
if [ $? -ne 0 ]; then
    echo "Error: $download_result"
    exit 1
fi

# Verify the downloaded file
if [ ! -s "$CORE_FILE" ]; then
    echo "Downloaded file is empty. Installation aborted."
    rm -f "$CORE_FILE"
    exit 1
fi

echo "Successfully downloaded gh_cli.sh"
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

# Reload the shell configuration
# source "$shell_config"

echo "gh-cli has been installed successfully. Please restart your terminal or run 'source $shell_config' to use gh-cli."
