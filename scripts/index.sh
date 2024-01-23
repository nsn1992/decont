# This script indexes the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2) if it didn´t exist.
genomefile="$1"
outdir="$2"
if [ -e "$outdir"/Log.out ]; then
	echo "An index already exists. The script will continue using it"
else
	STAR --runThreadN 4 --runMode genomeGenerate --genomeDir "$outdir" --genomeFastaFiles "$genomefile" --genomeSAindexNbases 9
fi
