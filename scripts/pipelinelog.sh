# Extract data of cutadapt and the alignment using grep and awk. The sample id is taken as first argument $1.
# All the information is stored in a new file Log.out.
sidt="$1"
input_cutadapt_log="log/cutadapt/${sidt}.log"
reads_adapters=$(grep '^Reads with adapters' "${input_cutadapt_log}" | cut -d "(" -f2 | sed 's#)##')
total_basepairs=$(grep '^Total basepairs processed' "${input_cutadapt_log}" | awk '{print $(NF-1),$NF}')
star_log="out/star/${sidt}/Log.final.out"
uniq_reads=$(awk '/.*Uniquely mapped reads %/{print $NF}' "${star_log}")
multiple_loci=$(awk '/.*% of reads mapped to multiple loci/{print $NF}' "${star_log}")
many_loci=$(awk '/.*% of reads mapped to too many loci/{print $NF}' "${star_log}") 
echo "${sidt}: Reads with adapters= ${reads_adapters},Total basepairs= ${total_basepairs}, Uniquely mapped reads= ${uniq_reads}, \
Reads mapped to multiple loci= ${multiple_loci},Reads mapped to too many loci= ${many_loci}" >> Log.out
