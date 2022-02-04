process index_bam {
        label 'bam'
        publishDir "${params.outdir}", mode: 'copy', pattern: '*.bai'

        input:
        path(bam_track)
	val(singularity_ok)

        output:
        path("*.bai"), emit: bai_file

        script:
        """
        bam.sh ${bam_track} >& bam_index.log 2>&1

        if  test -f "${params.outdir}/${bam_track}"
        then
                echo "${params.outdir}/${bam_track} already in ${params.outdir}:  do not copy it" >& already_bam.log 2>&1
        else

		cp -i -u ${bam_track} ${params.outdir} >& bam_cp.log 2>&1
	fi

        """
}

