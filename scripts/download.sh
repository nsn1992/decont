# Function to check the integrity of the downloaded files (this function takes 2 arguments). 
check_integrity (){ 
	local digital_url="$1"
    	local local_file="$2"
	remote_md5=$(curl -s "${digital_url}".md5 | cut -d " " -f1)
	local_md5=$(md5sum "${local_file}" | cut -d " " -f1)
	if [ "${remote_md5}" == "${local_md5}" ]; then
		echo "File correctly downloaded from ${digital_url}"
	else
		echo "File downloaded from ${digital_url} is corrupted"
		exit 1
	fi
}
# Check the number of arguments. If there are not at least 2 an error message is provided indicating how to execute the script.
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <url/path to the urls file> <out_directory> [uncompress:yes/no (only with url as first argument)] [word_to_filter(snRNA)(only with url as first argument)]"
    exit 1
fi
# Names assignation to the arguments.
url_name="$1"
out_directory="$2"
uncompress="$3"
word_to_filter="$4"
# Creation of an output directory if it didn't exist.
mkdir -p "$out_directory"
# An if-else sentence checks if url_name can be a path to a file with the urls (data/urls) or an url (contaminants).
if [ -f "$url_name" ]; then
	# Files from the urls file are download to the out_directory (option -i reads from the file and -c avoids the generation of duplicates).
	wget -c -P "$out_directory" -i "$url_name"
	# Check download integrity of the files comparing md5 hashes of the remote/digital link of the file and the local file.
	for url in $(cat "$url_name"); do 
		check_integrity "$url" "$out_directory/$(basename "$url")"
	done 
	# Check if there are more of 2 arguments. In this case I don´t need to uncompress or filter the files because samples data can be processed directly.
	if [ "$uncompress" == "yes" ] || [ -n "$word_to_filter" ]; then
        	echo "Options for uncompression or fourth argument are only possible if the first argument is an url."
        	echo "Usage: $0 <url/path to the urls file> <out_directory> [uncompress:yes/no (only with url as first argument)] [word_to_filter(snRNA)(only with url as first argument)]"
    		exit 1
    	fi
else
	# The file is downloaded from the url provided. This would be the case for the contaminants link provided as first argument. The -c option avoids the generation
	# of duplicates.
	wget -c -P "$out_directory" "$url_name"
	# Check download integrity of the files comparing md5 hashes of the remote/digital link of the file and the local file.
	check_integrity "${url_name}" "$out_directory/$(basename "$url_name")"
	# Creation of a variable with the pathway to the uncompressed file which will be useful later.
	input_filter="$out_directory"/"$(basename "$url_name" .gz)"
	# I uncompress the file if requested and it didnt exist.
	if [ "$uncompress" == "yes" ]; then
        	if [ -e "$input_filter" ]; then
        		echo "The file had already been uncompressed. Skipping operation"
        	else
        		gunzip -k "$out_directory"/"$(basename "$url_name")"
        		echo "The contaminants file has been uncompressed and stored in $input_filter"
       		fi
	fi
	# If a fourth argument is provided with the filter word (snRNA should be introduced): I must eliminate sequences and headers in the fasta input file containing this 
	# filter word or the words small nuclear RNA. To do that I use the seqkit package of bioconda combined with grep. Before I check if the filtered file existed previously.
	if [ -n "$word_to_filter" ]; then
		filtered_file="$out_directory/filtered_contaminants.fasta"
		if [ -e "$filtered_file" ]; then
        		echo "The file had already been filtered. Skipping operation"
       	 	else
			seqkit grep -n -v -r -p "($word_to_filter|small nuclear RNA)" "$input_filter" > "$filtered_file"
			echo "The file has been filtered and a filtered_contaminants.fasta has been generated"
		fi
	fi
fi
