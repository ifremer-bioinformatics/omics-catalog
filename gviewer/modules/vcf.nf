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
	
        if  test -f "${params.outdir}/${vcf_track}"
        then
                echo "${params.outdir}/${vcf_track} already in ${params.outdir}:  do not copy it" >& already_vcf.log 2>&1
        else
	
		cp -i -u ${vcf_track} ${params.outdir} >& bam_cp.log 2>&1
	fi

        """
}

