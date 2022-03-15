process index_fasta {
	label 'fasta'
	publishDir "${params.outdir}", mode: 'copy', pattern: '*.fai'

	input:
	path(genome) 
	val(singularity_ok)

	output:
	path("*.fai"), emit: fai_file

	script:
	"""
	fasta.sh ${genome} >& fasta_index.log 2>&1

        if  test -f "${params.outdir}/${genome}"
        then
                echo "${params.outdir}/${genome} already in ${params.outdir}:  do not copy it" >& already_genome.log 2>&1
        else

		cp -i -u ${genome} ${params.outdir} >& genome_cp.log 2>&1

	fi
	"""

}
