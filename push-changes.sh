#!/bin/bash

# Check if module name and commit message are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <module-name> <commit-message>"
    echo "Available modules: bff, tr, ma, mi, rs, all"
    exit 1
fi

MODULE=$1
shift
COMMIT_MSG="$*" # Allow spaces and new lines -> grab all remaining CLI args after the module name + quote all $module paths in case you ever use spaces

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to check if repo is in sync with remote
check_sync() {
    local module=$1
    local needs_sync=0
    
    if [ -n "$module" ]; then
        # Check submodule
        cd "$module" || handle_error "Failed to navigate to $module directory"
        git fetch origin
        git fetch upstream
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})
        if [ "$LOCAL" != "$REMOTE" ]; then
            needs_sync=1
        fi
        cd ..
    else
        # Check main repo
        git fetch origin
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u})
        if [ "$LOCAL" != "$REMOTE" ]; then
            needs_sync=1
        fi
    fi
    
    return $needs_sync
}

# Check if repositories need synchronization
echo "Checking repository synchronization..."
needs_update=0

# Check main repository
if check_sync; then
    echo "Main repository is up to date"
else
    echo "Main repository needs to be synchronized"
    needs_update=1
fi

# Check specified module or all modules
if [ "$MODULE" = "all" ]; then
    for module in bff tr ma mi rs; do
        if check_sync "$module"; then
            echo "$module is up to date"
        else
            echo "$module needs to be synchronized"
            needs_update=1
        fi
    done
else
    if check_sync "$MODULE"; then
        echo "$MODULE is up to date"
    else
        echo "$MODULE needs to be synchronized"
        needs_update=1
    fi
fi

# If any repository needs update, run pull-changes.sh
if [ $needs_update -eq 1 ]; then
    echo "Some repositories need to be synchronized. Running pull-changes.sh..."
    ./pull-changes.sh || handle_error "Failed to synchronize repositories"
fi

# Function to process a single module
process_module() {
    local module=$1
    local commit_msg=$2
    
    echo "Processing module: $module"
    
    # Navigate to the module directory
    cd "$module" || handle_error "Failed to navigate to $module directory"
    
    # Add all changes
    git add . || handle_error "Failed to add changes in $module"
    
    # Check if there are any changes to commit
    if [ -z "$(git status --porcelain)" ]; then
        echo "No changes to commit in $module"
        cd ..
        return
    fi
    
    # Commit changes
    git commit -m "$commit_msg" || handle_error "Failed to commit changes in $module"
    
    # Push to origin
    echo "Pushing to origin..."
    git push origin main || handle_error "Failed to push to origin in $module"
    
    # Push to upstream
    echo "Pushing to upstream..."
    git push upstream main || handle_error "Failed to push to upstream in $module"
    
    # Return to monorepo root
    cd ..
    
    # Update the submodule reference in the monorepo
    echo "Updating submodule reference in monorepo..."
    git add "$module" || handle_error "Failed to add submodule changes to monorepo"
    
    echo "Successfully processed $module"
}

# Process all modules
if [ "$MODULE" = "all" ]; then
    # Process each module
    for module in bff tr ma mi rs; do
        process_module "$module" "$COMMIT_MSG"
    done
    
    # Commit and push root changes
    if [ -n "$(git status --porcelain)" ]; then
        git add . || handle_error "Failed to add changes in monorepo"
        git commit -m "(all submodules) $COMMIT_MSG" || handle_error "Failed to commit submodule changes in monorepo"
        git push origin main || handle_error "Failed to push monorepo changes"
    fi
    
    echo "Successfully pushed all changes for all modules"
else
    # Validate single module name
    case "$MODULE" in
        bff|tr|ma|mi|rs)
            process_module "$MODULE" "$COMMIT_MSG"
            
            # commit & push root pointer
            if [ -n "$(git status --porcelain)" ]; then
                git commit -m "(submodule $MODULE) $COMMIT_MSG" \
                    || handle_error "Failed to commit submodule pointer"
                git push origin main \
                    || handle_error "Failed to push monorepo changes"
            fi
            ;;
        *)
            echo "Error: Invalid module name. Available modules: bff, tr, ma, mi, rs, all"
            exit 1
            ;;
    esac
fi 