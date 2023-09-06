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


keep(){
    if [[ -z "$1" ]]; then # filename was provided
        echo "Usage: backup_file <filename>"
        return 1
    fi

    if [[ ! -e "$1" ]]; then # file exists
        echo "Error: File '$1' does not exist."
        return 1
    fi

    local filename=$(basename "$1")
    local date=$(date '+%Y%m%d')
    local dtime=$(date '+%Y%m%d_%H%M%S')

    local dest_dir="$HOME/keep/keep_${date}"
    mkdir -p "${dest_dir}"

    local dest_path="${dest_dir}/keep_${dtime}_$fn"

    if [[ -e "${dest_path}" ]]; then
        echo "Error: A keep copy of the file already exists at ${dest_path}."
        return 1
    fi

    # Use -L to ensure we copy the actual file if it's a symbolic link
    cp -L "$1" "${dest_path}"

    echo "Keeping a copy of '$1' at '${dest_path}'"
}
