process jbrowse2_vcf {
        label 'jbrowse2'


        input:
	path(vcf_file)
        each path(vcf_gz_file)
	val(add_assembly_ok)
        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """
	
	if  [ -f "${params.outdir}/jbrowse2/${vcf_gz_file}" ]
        then
                echo "${params.outdir}/jbrowse2/${vcf_gz_file} already exists, do not add it to jborwse/" >& already_vcf_gz_file_jbrowse2.log 2>&1
        else
        	/opt/exec_jbrowse.sh ${params.outdir} ${vcf_gz_file} >& vcf_jbrowse2.log 2>&1
        	/opt/fix_symlink.sh ${params.outdir} ${vcf_gz_file} ${vcf_gz_file}.tbi >& fix_vcf_symlink.log 2>&1
	fi

        """
}

