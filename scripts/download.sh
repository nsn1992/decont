# Firstly I check that the number of arguments is at least 2. If not I give an error message indicating how to execute the script
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <url_name> <out_directory> [uncompress:yes/no] [word_to_filter(snRNA)]"
    exit 1
fi

url_name="$1"
out_directory="$2"
uncompress="$3"
word_to_filter="$4"

# I create an output directory if it doesn't exist.
mkdir -p "$out_directory"

# url_name can be a path to a file with the urls (data/urls) or an url (contaminants)so I have to check what option I have in order to use wget in the right way.

if [ -f "$url_name" ]; then
	# I download the files from the urls file to the out_directory (option -i reads from the file)
	wget -P "$out_directory" -i "$url_name"
	# Check download integrity of the files. To do that I compare the md5 checksum of the remote link of the file and the local file.
	for url in $(cat "$url_name"); do 
		remote_md5=$(curl -s "$url".md5 | cut -d " " -f1)
		local_md5=$(md5sum "$out_directory"/$(basename "$url") | cut -d " " -f1)
		if [ "${remote_md5}" == "${local_md5}" ]; then
			echo "File correctly downloaded from $url"
		else
			echo "File downloaded from $url is corrupted"
			exit 1
		fi
	done 
else
	# I download the file of the url provided. This would be the case for the contaminants link provided as first argument.
	wget -P "$out_directory" "$url_name"
	# Check download integrity of the files. To do that I compare the md5 checksum of the remote link of the file and the local file.
	remote_md5=$(curl -s "$url_name".md5 | cut -d " " -f1)
	local_md5=$(md5sum "$out_directory"/$(basename "$url_name") | cut -d " " -f1)
	if [ "${remote_md5}" == "${local_md5}" ]; then
		echo "File correctly downloaded from $url_name"
	else
		echo "File downloaded from $url_name is corrupted"
		exit 1
	fi
fi
# I create a variable with the pathway to the uncompressed file.This is useful for the next ifś sentences.
input_filter="$out_directory"/"$(basename "$url_name" .gz)"
# I uncompress the file if requested and it doesn´t exist
if [ "$uncompress" == "yes" ]; then
        if [ -e "$input_filter" ]; then
        	echo "The file had already been uncompressed. The script will continue"
        else
        	gunzip -k "$out_directory"/"$(basename "$url_name")"
        	echo "The contaminants file has been uncompressed and stored in $input_filter"
        fi
fi
# If a four argument is provided with the filter word (snRNA should be introduced). I must eliminate headers in the fasta input file containing this 
# filter word or the words small nuclear RNA. To do that I use the seqkit package of bioconda combined with grep. Before I check if the filtered file existed previously.
if [ -n "$word_to_filter" ]; then
	filtered_file="$out_directory/filtered_contaminants.fasta"
	if [ -e "$filtered_file" ]; then
        	echo "The file had already been filtered. The script will continue with the previous filtered one"
        else
		seqkit grep -n -v -r -p "($word_to_filter|small nuclear RNA)" "$input_filter" > "$filtered_file"
		echo "The file has been filtered and a filtered_contaminants.fasta has been generated"
	fi
fi


