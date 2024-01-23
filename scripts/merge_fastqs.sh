# This script merges all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file and stores this 
# file in the output directory specified by the second argument ($2) if it didn´t exist.
# The directory containing the samples is indicated by the first argument ($1=data).
input_dir="$1"
out_dir="$2"
sample_id="$3"
mkdir -p "$out_dir"
out_file="$out_dir/${sample_id}.fastq.gz"
if [ -e "${out_file}" ]; then
	echo "The merged output file for ${sample_id} already exists. The script will continue using it"
else
	find "$input_dir" -name "${sample_id}*.fastq.gz" -exec cat {} + > "$out_file"
fi

