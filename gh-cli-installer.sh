gh_core="https://raw.githubusercontent.com/Groos-dev/github-cli/refs/heads/main/gh-cli.sh"
# Create the directory if it doesn't exist
mkdir -p ~/.gh-cli/bin

# Download the gh-cli script
curl -sSL "$gh_core" -o ~/.gh-cli/bin/gh-cli

# Make the script executable
chmod +x ~/.gh-cli/bin/gh-cli

# Add ~/.gh-cli/bin to PATH in the appropriate shell configuration file
shell_config="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    shell_config="$HOME/.zshrc"
fi

# Check if the PATH is already updated
if ! grep -q 'export PATH="$HOME/.gh-cli/bin:$PATH"' "$shell_config"; then
    echo 'export PATH="$HOME/.gh-cli/bin:$PATH"' >> "$shell_config"
    echo "PATH has been updated in $shell_config"
else
    echo "PATH already contains ~/.gh-cli/bin"
fi

# Reload the shell configuration
# source "$shell_config"

echo "gh-cli has been installed successfully. Please restart your terminal or run 'source $shell_config' to use gh-cli."
