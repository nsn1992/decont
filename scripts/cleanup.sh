# I create a function to remove the contents of a directory if it exists.
remove_dir_contents() {
    if [ -d "$1" ]; then
        rm -rf "$1"/*
        echo "$1 contents have been removed if it was not already empty"
    fi
}
# I make an if sentence to remove all directories content when no arguments are passed.
if [ "$#" -eq 0 ]; then
    for dir in "data" "res" "out" "log"; do 
        if [ "$dir" == "data" ]; then
            rm -f "$dir"/*.fastq.gz
            echo "$dir contents have been removed if it was not already empty"
        else
            remove_dir_contents "$dir"
        fi
    done
fi
# I use another if sentence to remove the directories content the user wants.
if [ "$#" -ne 0 ]; then
    for arg in "$@"; do
        if [ "$arg" == "data" ]; then
            rm -f "$arg"/*.fastq.gz
            echo "$arg contents have been removed if it was not already empty"
        else
            remove_dir_contents "$arg"
        fi
    done
fi
