process jbrowse2_vcf {
        label 'jbrowse2'


        input:
	each path(vcf_file)
        path(vcf_gz_file)
	val(add_assembly_ok)
        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """
	
	if  test -f "${params.outdir}/jbrowse2/${vcf_file}"
        then
                echo "${params.outdir}/jbrowse2/${vcf_file} already exists, do not add it to jborwse/" >& already_bam_jbrowse2.log 2>&1
        else
        	/opt/exec_jbrowse.sh ${params.outdir} ${vcf_gz_file} >& vcf3_jbrowse2.log 2>&1
        	/opt/fix_symlink.sh ${params.outdir} ${vcf_gz_file} ${vcf_gz_file}.tbi >& fix_vcf_symlink.log 2>&1
	fi

        """
}

