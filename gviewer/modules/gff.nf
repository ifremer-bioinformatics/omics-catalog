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
	cp -i -u ${gff_track} ${params.outdir} >& bam_cp.log 2>&1
        """
}

