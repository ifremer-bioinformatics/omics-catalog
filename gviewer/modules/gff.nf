process index_gff {
        label 'gff'
        publishDir "${params.outdir}", mode: 'copy', pattern: '*.gff.gz*'

        input:
        path(gff_track)
	val(singularity_ok)

        output:
        path("*.gff.gz*")
        path("*.gff.gz"), emit: gff_gz_file

        script:
        """
        gff.sh ${gff_track} >& gff_index.log 2>&1

        if  test -f "${params.outdir}/${gff_track}"
        then
                echo "${params.outdir}/${gff_track} already in ${params.outdir}:  do not copy it" >& already_gff.log 2>&1
        else
		cp -i -u ${gff_track} ${params.outdir} >& bam_cp.log 2>&1
        
	fi
	"""
}

