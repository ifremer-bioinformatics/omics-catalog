process index_gff3 {
        label 'gff3'
        publishDir "${params.outdir}", mode: 'copy', pattern: '*.gff3.gz*'

        input:
        path(gff3_track)
	val(singularity_ok)

        output:
        path("*.gff3.gz*")
        path("*.gff3.gz"), emit: gff3_gz_file

        script:
        """
        gff3.sh ${gff3_track} >& gff3_index.log 2>&1
        """
}

