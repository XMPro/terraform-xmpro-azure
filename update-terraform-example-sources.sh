#!/bin/bash
# Script to update Terraform example source references based on branch context
# Used by github-push-changes.yml to ensure examples reference the correct version

set -e

# Get the branch name from the argument or environment variable
BRANCH_NAME="${1:-$BUILD_SOURCEBRANCHNAME}"

echo "Updating Terraform example sources for branch: $BRANCH_NAME"

# Check if this is a release branch
if [[ "$BRANCH_NAME" == release-* ]]; then
    echo "Release branch detected: $BRANCH_NAME"
    
    # Extract version from branch name (e.g., release-4.5.2 -> 4.5.2)
    VERSION=$(echo "$BRANCH_NAME" | sed 's/release-//')
    echo "Version extracted: $VERSION"
    
    SOURCE_REF="?ref=v$VERSION"
    echo "Source reference will be: github.com/XMPro/terraform-xmpro-azure${SOURCE_REF}"
    
    # Update all example main.tf files
    if [ -d "examples" ]; then
        echo "Found examples directory, updating source references..."
        
        for example_dir in examples/*/; do
            if [ -f "${example_dir}main.tf" ]; then
                echo "Processing ${example_dir}main.tf"
                
                # Create a backup for safety
                cp "${example_dir}main.tf" "${example_dir}main.tf.bak"
                
                # 1. Comment out the generic GitHub source line (without ref)
                # Match with or without trailing whitespace
                sed -i 's|^\(\s*\)source = "github.com/XMPro/terraform-xmpro-azure"|\1# source = "github.com/XMPro/terraform-xmpro-azure"|g' "${example_dir}main.tf"
                
                # 2. Update the comment text to indicate this is the release version
                sed -i "s|# For a specific version:|# Using release version:|g" "${example_dir}main.tf"
                
                # 3. Uncomment and update the version-specific line
                # First, try to uncomment if it's commented
                sed -i "/# Using release version:/,/^[[:space:]]*$/ s|^\(\s*\)# source = \"github.com/XMPro/terraform-xmpro-azure?ref=.*\"|\1source = \"github.com/XMPro/terraform-xmpro-azure${SOURCE_REF}\"|" "${example_dir}main.tf"
                
                # 4. Update any already uncommented version-specific lines
                sed -i "s|^\(\s*\)source = \"github.com/XMPro/terraform-xmpro-azure?ref=.*\"|\1source = \"github.com/XMPro/terraform-xmpro-azure${SOURCE_REF}\"|g" "${example_dir}main.tf"
                
                # 5. Handle module subdirectory references (e.g., //modules/resource-group)
                # Comment out generic module references (without ref parameter)
                sed -i 's|^\(\s*\)source = "github.com/XMPro/terraform-xmpro-azure//modules/\([^"]*\)"$|\1# source = "github.com/XMPro/terraform-xmpro-azure//modules/\2"|g' "${example_dir}main.tf"
                
                # Uncomment and update version-specific module references
                sed -i "s|^\(\s*\)# source = \"github.com/XMPro/terraform-xmpro-azure//modules/\([^\"]*\)?ref=.*\"|\1source = \"github.com/XMPro/terraform-xmpro-azure//modules/\2${SOURCE_REF}\"|g" "${example_dir}main.tf"
                
                # Update already uncommented version-specific module references
                sed -i "s|^\(\s*\)source = \"github.com/XMPro/terraform-xmpro-azure//modules/\([^\"]*\)?ref=.*\"|\1source = \"github.com/XMPro/terraform-xmpro-azure//modules/\2${SOURCE_REF}\"|g" "${example_dir}main.tf"
                
                # Remove backup if everything succeeded
                rm -f "${example_dir}main.tf.bak"
                
                echo "Updated ${example_dir}main.tf successfully"
            fi
            
            # Update terraform.tfvars.example file if it exists
            if [ -f "${example_dir}terraform.tfvars.example" ]; then
                echo "Processing ${example_dir}terraform.tfvars.example"
                
                # Create a backup for safety
                cp "${example_dir}terraform.tfvars.example" "${example_dir}terraform.tfvars.example.bak"
                
                # Update the imageversion line to use the extracted version
                sed -i "s|^imageversion = \".*\"|imageversion = \"$VERSION\"|g" "${example_dir}terraform.tfvars.example"
                
                # Remove backup if everything succeeded
                rm -f "${example_dir}terraform.tfvars.example.bak"
                
                echo "Updated ${example_dir}terraform.tfvars.example with imageversion = \"$VERSION\""
            fi
        done
        
        echo "All example files updated successfully"
    else
        echo "No examples directory found"
    fi
else
    echo "Non-release branch detected: $BRANCH_NAME"
    echo "Keeping default source references (no changes needed)"
fi