process jbrowse2_gff3 {
        label 'jbrowse2'


        input:
	path(gff3_file)
        each path(gff3_gz_file)
	val(add_assembly_ok)
        val(singularity_ok)

        output:
        path('*.log'), emit: adding_ok

        script:
        """


	if  [ -f "${params.outdir}/jbrowse2/${gff3_gz_file}" ]
        then
                echo "opt/jbrowse2/${gff3_gz_file} already exists, do not add it to jborwse/" >& already_gff3_jbrowse2.log 2>&1
        else
        	/opt/exec_jbrowse.sh ${params.outdir} ${gff3_gz_file} >& gff3_jbrowse2.log 2>&1
        	/opt/fix_symlink.sh ${params.outdir} ${gff3_gz_file} ${gff3_gz_file}.tbi >& fix_gff3_symlink.log 2>&1

        fi
	"""
}

