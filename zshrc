# zshrc

# srm: safe remove
srm() {
    local files_to_delete=()
    local params=()

    # Separate files and parameters
    for arg in "$@"; do
        if [[ $arg == -* ]]; then
            params+=("$arg")
        else
            files_to_delete+=("$arg")
        fi
    done
    
    if (( ${#files_to_delete[@]} == 0 )); then
        echo "No files specified for deletion."
        return 1
    fi
    
    echo "Files to delete:"
    printf "%s\n" "${files_to_delete[@]}" | less -FX
    
    read -q "yn?Proceed with deleting the listed files? (y/n) "
    echo
    
    if [[ $yn == [Yy] ]]; then
        rm "${params[@]}" -v "${files_to_delete[@]}"
    else
        echo "Deletion cancelled."
    fi
}

