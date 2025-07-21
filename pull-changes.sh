#!/bin/bash

# Check if module name is provided
if [ $# -gt 1 ]; then
    echo "Usage: $0 [module-name]"
    echo "Available modules: bff, tr, ma, mi, rs, all"
    echo "If no module is specified, 'all' is assumed"
    exit 1
fi

MODULE=${1:-all}  # Default to 'all' if no argument provided

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to process a single module
process_module() {
    local module=$1
    
    echo "Pulling changes for module: $module"
    
    # Navigate to the module directory
    cd "$module" || handle_error "Failed to navigate to $module directory"
    
    # Fetch all branches from both remotes
    echo "Fetching from remotes..."
    git fetch --all || echo "Warning: Failed to fetch from remotes in $module"
    
    # Check if origin exists
    if git remote get-url origin >/dev/null 2>&1; then
        echo "Pulling from origin main..."
        git pull origin main || echo "Warning: Failed to pull from origin in $module"
    else
        echo "Warning: No origin remote found in $module"
    fi
    
    # Return to monorepo root
    cd ..
    
    echo "Successfully processed $module"
}

# Process all modules
if [ "$MODULE" = "all" ]; then
    # First pull the root repo
    echo "Pulling changes for root repository..."
    git pull origin main || handle_error "Failed to pull main from root repository"
    
    # Fetch submodules without updating
    echo "Fetching submodules..."
    git submodule foreach 'git fetch --all' || echo "Warning: Some submodule fetches failed"
    
    # Process each module
    for module in bff tr ma mi rs; do
        process_module "$module"
    done
    
    # Now try to update submodules
    echo "Updating submodules to their correct commits..."
    git submodule update || echo "Warning: Some submodules could not be updated to their correct commits"
    
    echo "Pull process completed. Please check for any warnings above."
else
    # Validate single module name
    case "$MODULE" in
        bff|tr|ma|mi|rs)
            process_module "$MODULE"
            ;;
        *)
            echo "Error: Invalid module name. Available modules: bff, tr, ma, mi, rs, all"
            exit 1
            ;;
    esac
fi 