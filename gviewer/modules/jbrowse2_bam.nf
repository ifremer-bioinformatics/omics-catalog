process jbrowse2_bam {
        label 'jbrowse2'


        input:
        each path(bam_file)
        path(bai_file)
	val(add_assembly_ok)
        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """

        if [ -f "${params.outdir}/jbrowse2/${bam_file}" ]
        then
                echo "${params.outdir}/jbrowse2/${bam_file} already exists, do not add it to jborwse/" >& already_bam_jbrowse2.log 2>&1
        else
	        /opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} >& bam_jbrowse2.log 2>&1
        	/opt/fix_symlink.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} ${bam_file}.bai  >& fix_bam_symlink.log 2>&1
	fi

        """
}

