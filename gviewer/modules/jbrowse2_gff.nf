process jbrowse2_gff {
        label 'jbrowse2'


        input:
	each path(gff_file)
        path(gff_gz_file)
	val(add_assembly_ok)
        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """
	
	if  test -f "${params.outdir}/jbrowse2/${gff_gz_file}"
        then
                echo "${params.outdir}/jbrowse2/${gff_gz_file} already exists, do not add it to jborwse/" >& already_gff_jbrowse2.log 2>&1
        else
        	/opt/exec_jbrowse.sh ${params.outdir} ${gff_gz_file} >& gff_jbrowse2.log 2>&1
        	/opt/fix_symlink.sh ${params.outdir} ${gff_gz_file} ${gff_gz_file}.tbi >& fix_gff_symlink.log 2>&1
	fi
	
        """
}

