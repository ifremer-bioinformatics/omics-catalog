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
        """
}

