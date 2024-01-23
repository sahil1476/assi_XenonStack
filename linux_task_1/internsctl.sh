#!/bin/bash

# Define the command version
VERSION="v0.1.0"

# Function to display the manual page
function show_manual() {
    echo "internsctl - Custom Linux Command"
    echo "Version: $VERSION"
    echo
    echo "DESCRIPTION:"
    echo "    internsctl is a custom Linux command for various operations."
    echo
    echo "OPTIONS:"
    echo "    cpu getinfo       Get CPU information (similar to lscpu command)"
    echo "    memory getinfo    Get memory information (similar to free command)"
    echo "    user create       Create a new user"
    echo "    user list          List all regular users"
    echo "    user list --sudo-only   List users with sudo permissions"
}

# Function to display help
function show_help() {
    echo "Usage: internsctl [OPTIONS]"
    echo
    echo "OPTIONS:"
    echo "    --help             Display this help message"
    echo "    --version          Display command version"
    echo "    cpu getinfo        Get CPU information"
    echo "    memory getinfo     Get memory information"
    echo "    user create        Create a new user (provide username as argument)"
    echo "    user list          List all regular users"
    echo "    user list --sudo-onl   List users with sudo permissions"
}

# Function to get CPU information
function get_cpu_info() {
    lscpu
}

# Function to get memory information
function get_memory_info() {
    free
}

# Function to create a new user
function create_user() {
    if [ -z "$1" ]; then
        echo "Error: Please provide a username."
        exit 1
    fi
    sudo useradd -m "$1"
    echo "User '$1' created successfully."
}

# Function to list users
function list_users() {
    if [ "$1" == "--sudo-only" ]; then
        getent passwd | cut -d: -f1,3,4 | awk -F: '$2 >= 1000 {print $1}' | xargs groups | grep -E '\bsudo\b' | cut -d: -f1
    else
        getent passwd | cut -d: -f1
    fi
}

# Function to get file information
function get_file_info() {
    if [ -z "$1" ]; then
        echo "Error: Please provide a file name."
        exit 1
    fi

    FILENAME="$1"
    FILE_EXISTS=$(test -e "$FILENAME" && echo "true" || echo "false")

    if [ "$FILE_EXISTS" == "false" ]; then
        echo "Error: File '$FILENAME' not found."
        exit 1
    fi

    if [ "$2" == "--size" ] || [ "$2" == "-s" ]; then
        stat -c "%s" "$FILENAME"  # Print size
    elif [ "$2" == "--permissions" ] || [ "$2" == "-p" ]; then
        stat -c "%A" "$FILENAME"  # Print permissions
    elif [ "$2" == "--owner" ] || [ "$2" == "-o" ]; then
        stat -c "%U" "$FILENAME"  # Print owner
    elif [ "$2" == "--last-modified" ] || [ "$2" == "-m" ]; then
        stat -c "%y" "$FILENAME"  # Print last modified time
    else
        # Default output
        echo "File: $FILENAME"
        echo "Access: $(stat -c '%A' "$FILENAME")"
        echo "Size(B): $(stat -c '%s' "$FILENAME")"
        echo "Owner: $(stat -c '%U' "$FILENAME")"
        echo "Modify: $(stat -c '%y' "$FILENAME")"
    fi
}

# Main script logic
case "$1" in
    "cpu" )
        shift
        case "$1" in
            "getinfo" )
                get_cpu_info
                ;;
            * )
                show_help
                ;;
        esac
        ;;
    "memory" )
        shift
        case "$1" in
            "getinfo" )
                get_memory_info
                ;;
            * )
                show_help
                ;;
        esac
        ;;
    "user" )
        shift
        case "$1" in
            "create" )
                shift
                create_user "$1"
                ;;
            "list" )
                shift
                list_users "$1"
                ;;
    "file" )
        shift
        case "$1" in
            "getinfo" )
                shift
                get_file_info "$1" "$2"
                ;;
            * )
                show_help
                ;;
        esac
        ;;
            * )
                show_help
                ;;
        esac
        ;;
    "--help" )
        show_help
        ;;
    "--version" )
        echo "internsctl version $VERSION"
        ;;
    * )
        show_help
        ;;
esac

#chmod +x internsctl.sh
#./internsctl.sh --help
#./internsctl.sh cpu getinfo
#./internsctl.sh memory getinfo
#./internsctl.sh user create newuser
#./internsctl.sh user list
#./internsctl.sh user list --sudo-only
