process jbrowse2_bam {
        label 'jbrowse2'


        input:
        each file(bam_file)
        path(bai_file)
	val(add_assembly_ok)
        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """

        /opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} >& test_bam_jbrowse2.log 2>&1
        /opt/fix_symlink.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} ${bam_file}.bai  >& test_fix_bam_symlink.log 2>&1


        """
}

