process index_vcf {
        label 'vcf'
        publishDir "${params.outdir}", mode: 'copy', pattern: '*.vcf.gz*'

        input:
        path(vcf_track)
	val(singularity_ok)

        output:
        path("*.vcf.gz*")
        path("*.vcf.gz"), emit: vcf_gz_file

        script:
        """
        vcf.sh ${vcf_track} >& vcf_index.log 2>&1
        """
}

