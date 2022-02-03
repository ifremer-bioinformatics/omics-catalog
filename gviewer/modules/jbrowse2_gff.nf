process jbrowse2_gff {
        label 'jbrowse2'


        input:
	file(gff_file)
        file(gff_gz_file)

        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """

        /opt/exec_jbrowse.sh ${params.outdir} ${gff_gz_file} >& gff_jbrowse2.log 2>&1
        /opt/fix_symlink.sh ${params.outdir} ${gff_gz_file} ${gff_gz_file}.tbi >& fix_gff_symlink.log 2>&1

        """
}

