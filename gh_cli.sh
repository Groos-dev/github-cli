#!/bin/bash

# Custom GitHub CLI Tool: gh-cli
# Usage: gh-cli create repo -d "description"

# Set red color for error messages
RED='\033[0;31m'
# Set green color for success messages
GREEN='\033[0;32m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'

# GitHub API base URL
GITHUB_API="https://api.github.com"
# Configuration file storing GitHub personal access token
ACCOUNT_INFO_FILE="$HOME/.gh-cli/account-info"

# Function to get or set GitHub token
get_or_set_token() {
    if [ ! -f "$ACCOUNT_INFO_FILE" ]; then
        create_token_file
    else
        read_and_validate_token
    fi
}

create_token_file() {
    echo -e "${RED}Error: Account information file not found.${NC}"
    echo "Please enter your GitHub Personal Access Token:"
    read github_token
    while [ -z "$github_token" ]; do
        echo "Token cannot be empty. Please enter your GitHub Personal Access Token:"
        read github_token
    done

    mkdir -p "$(dirname "$ACCOUNT_INFO_FILE")"
    echo "github_token=$github_token" >"$ACCOUNT_INFO_FILE"
    echo -e "${GREEN}Token saved successfully.${NC}"
}

read_and_validate_token() {
    # shellcheck source="$HOME/.gh-cli/account-info"
    source "$ACCOUNT_INFO_FILE"

    if [ -z "$github_token" ]; then
        echo -e "${YELLOW}GitHub token is empty. Please enter a new token:${NC}"
        read -s github_token
        echo "github_token=$github_token" >"$ACCOUNT_INFO_FILE"
        echo -e "${GREEN}Token saved successfully.${NC}"
    fi
    # shellcheck source="$HOME/.gh-cli/account-info"
    source "$ACCOUNT_INFO_FILE"
}

update_github_token() {
    echo -e "${YELLOW}Please enter your GitHub token:${NC}"
    read -r new_token

    # Update the token in the ACCOUNT_INFO_FILE
    if [ -f "$ACCOUNT_INFO_FILE" ]; then
        sed -i "s/github_token=.*/github_token=$new_token/" "$ACCOUNT_INFO_FILE"
    else
        echo "github_token=$new_token" >"$ACCOUNT_INFO_FILE"
    fi

    echo -e "${GREEN}github_token updated successfully.${NC}"
    github_token=$new_token
}
# Function to create a GitHub repository
function create_repo() {
    # Call the function to get or set the token
    get_or_set_token

    # Verify that token is not empty
    if [ -z "$github_token" ]; then
        echo -e "${RED}Error: GitHub token is missing or empty.${NC}"
        echo "Please check your $ACCOUNT_INFO_FILE file or re-run the script to enter a new token."
        exit 1
    fi

    # Ensure a repository name is provided
    if [[ -z "$1" ]]; then
        echo "Repository name required."
        exit 1
    fi

    # Ensure a description is provided
    if [[ -z "$2" ]]; then
        echo "Repository description required."
        exit 1
    fi

    local repo_name="$1"
    local repo_desc="$2"
    local is_private="${3:-false}"

    # Check if the repository directory already exists
    if [ ! -d "$repo_name" ]; then
        echo "Creating directory: $repo_name"
        mkdir "$repo_name"
    else
        echo "Directory $repo_name already exists."
    fi

    # Change to the repository directory
    cd "$repo_name" || exit 1
    echo "Changed working directory to: $(pwd)"
    # Send request to GitHub to create repository
    response=$(curl -s -X POST -H "Authorization: token $github_token" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"name\": \"$repo_name\", \"description\": \"$repo_desc\", \"private\": $is_private}" \
        "$GITHUB_API/user/repos")

    # Check response status
    if [[ $(echo "$response" | jq -r '.id') != "null" ]]; then
        echo -e "${GREEN}Repository '$repo_name' created successfully.${NC}"
        echo "Repository URL: $(echo "$response" | jq -r '.html_url')"

        # Create local repository and link to remote repository
        git init
        git remote remove origin
        git remote add origin "$(echo "$response" | jq -r '.ssh_url')" # Quoted to prevent word splitting
        echo "# $repo_name" >README.md
        git add .
        git commit -m "Initial commit"
        git branch -M main
        git push -u origin main

        echo -e "${GREEN}Local repository created and linked to remote repository.${NC}"
    else
        error_message=$(echo "$response" | jq -r '.message')
        echo -e "${RED}Failed to create repository. Error message: $error_message${NC}"
        if [[ "$error_message" == *"Bad credentials"* ]]; then
            echo -e "${RED}Bad credentials. Deleting account information file and clearing GitHub token.${NC}"
            rm -f "$ACCOUNT_INFO_FILE"
            unset github_token
            echo -e "${YELLOW}Account information has been deleted, GitHub token has been cleared from the environment.${NC}"
        else
            echo -e "${RED}Failed to create repository. Please check your input information and try again.${NC}"
            echo -e "${YELLOW}Error details: $error_message${NC}"
        fi
    fi
}

# Check for required dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v git &>/dev/null; then
        missing_deps+=("git")
    fi

    if ! command -v jq &>/dev/null; then
        missing_deps+=("jq")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Error: The following dependencies are missing:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}
# Function to delete a repository
delete_repo() {
    local repo_name="$1"
    echo "Deleting repository: $repo_name"

    # Ensure GitHub token is available
    if [ -z "$github_token" ]; then
        get_or_set_token
    fi

    # Get GitHub username
    github_username=$(curl -s -H "Authorization: token $github_token" \
        "$GITHUB_API/user" | jq -r '.login')
    echo "GitHub username: $github_username"

    # Confirm deletion
    read -p "Are you sure you want to delete the repository '$repo_name'? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Repository deletion cancelled.${NC}"
        return
    fi

    # Send DELETE request to GitHub API
    response=$(curl -s -X DELETE -H "Authorization: token $github_token" \
        "https://api.github.com/repos/$github_username/$repo_name")
    echo "Response: $response"

    # Check if the deletion was successful
    if [ -z "$response" ]; then
        echo -e "${GREEN}Repository '$repo_name' has been successfully deleted.${NC}"
    else
        error_message=$(echo "$response" | jq -r '.message')
        echo -e "${RED}Failed to delete repository. Error message: $error_message${NC}"
        if [[ "$error_message" == *"Bad credentials"* ]]; then
            echo -e "${RED}Bad credentials. Deleting account information file and clearing GitHub token.${NC}"
            rm -f "$ACCOUNT_INFO_FILE"
            unset github_token
            echo -e "${YELLOW}Account information has been deleted, GitHub token has been cleared from the environment.${NC}"
        else
            echo -e "${RED}Failed to delete repository. Please check your input information and try again.${NC}"
            echo -e "${YELLOW}Error details: $error_message${NC}"
        fi
    fi
}
help() {
    echo "Usage:"
    echo "  gh-cli --help                               Display this help message"
    echo "  gh-cli create <repo_name> [-d <description>] [-s <public|private>]   Create a new repository"
    echo "    <repo_name>                               Name of the repository to create"
    echo "    -d <description>                          Optional: Description of the repository"
    echo "    -s <public|private>                       Optional: Set repository visibility (default: public)"
    echo "  gh-cli delete <repo_name>                   Delete an existing repository"
    echo "    <repo_name>                               Name of the repository to delete"
    echo "  gh-cli update-cli                           Update the gh-cli tool to the latest version"
}

handle_commands() {
    if [ $# -eq 0 ]; then
        echo "${RED} Command error. ${NC}"
        help
        exit 1
    fi
    case $1 in
    create)
        REPO_NAME=$2
        shift 2

        # Initialize description variable as empty
        REPO_DESC="${REPO_NAME}"

        IS_PRIVATE="false"
        # Check if there is a -d parameter
        if [[ "$1" == "-d" ]]; then
            if [[ -n "$2" ]]; then
                REPO_DESC="$2" # Get the description content after -d
            else
                help
                exit 1
            fi

            if [ -n "$3" ]; then
                IS_PRIVATE="$3"
            fi
        fi
        create_repo "$REPO_NAME" "$REPO_DESC" "$IS_PRIVATE"
        ;;
    delete)
        if [ $# -ne 2 ]; then
            help
            exit 1
        fi
        REPO_NAME=$2
        delete_repo "$REPO_NAME"
        ;;
    update-cli)
        if [ $# -ne 2 ]; then
            if ./update_cli.sh; then
                echo -e "${GREEN}gh-cli updated successfully.${NC}"
            else
                echo -e "${RED}Failed to update gh-cli. Please check the error message above.${NC}"
                exit 1
            fi
        fi
        ;;
    *)
        echo -e "${RED}Error: Unsupported command '$1'.${NC}"
        echo "Supported commands: create, delete"
        ;;
    esac
}
# check dependencies
check_dependencies
# handle commands
handle_commands "$@"
