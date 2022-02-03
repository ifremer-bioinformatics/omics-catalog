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
	cp -i -u ${genome} ${params.outdir} >& bam_cp.log 2>&1

	"""

}
