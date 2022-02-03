process jbrowse2_vcf {
        label 'jbrowse2'


        input:
	path(vcf_file)
        path(vcf_gz_file)

        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """

        /opt/exec_jbrowse.sh ${params.outdir} ${vcf_gz_file} >& vcf3_jbrowse2.log 2>&1
        /opt/fix_symlink.sh ${params.outdir} ${vcf_gz_file} ${vcf_gz_file}.tbi >& fix_vcf_symlink.log 2>&1

        """
}

