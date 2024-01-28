# Download all the files specified in data/filenames.
echo "Downloading files of the urls file with the sample data"
bash scripts/download.sh data/urls data
# Download the contaminants fasta file, uncompress it, and filter to remove all small nuclear RNAs. In this case a fourth argument called snRNA refers to
# both snRNA and small nuclear RNA (see download.sh script), but we use snRNA to simplify the entry.If we had another word to filter different to snRNA
# we would have to change the filter in the download.sh script and use a different regular expression in the seqkit command.
echo "Downloading contaminants file, uncompressing and filtering it"
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes snRNA 
# Index the filtered contaminants file.
echo "Making and index with the contaminants file"
bash scripts/index.sh res/filtered_contaminants.fasta res/contaminants_idx
# Merge the samples into a single file.
echo "Merging the files for every sample"
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::' | sort | uniq) 
do
    bash scripts/merge_fastqs.sh data out/merged "$sid"
done
# Run cutadapt for all merged files only if they hadn´t been trimmed before.
echo "Running cutadapt for the merged files"
mkdir -p out/trimmed
mkdir -p log/cutadapt 
for input_merge_file in out/merged/*.fastq.gz; do
	sid_merge=$(basename "${input_merge_file}" .fastq.gz)
	if [ -e "out/trimmed/${sid_merge}.trimmed.fastq.gz" ]; then
		echo " "${sid_merge}" was already trimmed. Skipping operation"
	else
		echo "Trimming sample ${sid_merge}"
		cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o "out/trimmed/${sid_merge}.trimmed.fastq.gz" "${input_merge_file}" > "log/cutadapt/${sid_merge}.log"
	fi
done
# Run STAR for all trimmed files if they hadn´t been aligned before.
echo "Making the alignment with STAR"
for fname in out/trimmed/*.fastq.gz; do
	sidt=$(basename "$fname" .trimmed.fastq.gz)
	if [ -e "out/star/$sidt/" ]; then
		echo " $sidt was already aligned. Skipping."
		continue
	else
		echo " $sidt alignment"
		mkdir -p out/star/"$sidt"
		STAR --runThreadN 4 --genomeDir res/contaminants_idx \
        	--outReadsUnmapped Fastx --readFilesIn "$fname" \
       		--readFilesCommand gunzip -c --outFileNamePrefix  "out/star/$sidt/"
       	fi
# Extract data of cutadapt and the alignment using grep and awk .To do that I create an extra script called pipelinelog.sh
# and pass the name of every sample id as the first argument to execute it.After that a Log.out file is created with the
# required information.
	echo "Information of cutadapt and STAR alignment for ${sidt} is being added to Log.out"
	bash scripts/pipelinelog.sh ${sidt}
done
