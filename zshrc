# zshrc


# srm: safe remove
srm() {
    local files_to_delete=("$@")
    
    if (( $# == 0 )); then
        echo "No files specified"
        return 1
    fi
    
    echo "Files to delete:"
    printf "%s\n" "${files_to_delete[@]}" | less -FX
    
    read -q "yn?Proceed with deleting the listed files? (y/n) "
    echo
    
    if [[ $yn == [Yy] ]]; then
        rm -v "${files_to_delete[@]}"
    else
        echo "Deletion canceled"
    fi
}

