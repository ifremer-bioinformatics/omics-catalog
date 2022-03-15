process jbrowse2 {
        label 'jbrowse2'

        input:
	val(singularity_ok)
        each path(fasta_file)
        each path(bam_file)

	each path(fai_file)
	each path(bai_file)

        output:
        path('*.log'), emit: adding_ok

	script:
	"""
	
	if [ ! -d /opt/jbrowse2/${params.projectName}/${params.version}/jbrowse2 ]
	then
		mkdir /opt/jbrowse2/${params.projectName}/${params.version}/jbrowse2
	fi
		
	if [[ ${fasta_file} = *.fasta || ${fasta_file} = *.fna ]]
	then
	        if [ -f "${params.outdir}/jbrowse2/${fasta_file}" ]
	        then
        	        echo "${params.outdir}/jbrowse2/${fasta_file} already exists, do not add it to jborwse/" >& already_fasta_file_jbrowse2.log 2>&1
        	else
        		/opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${fasta_file} >& fasta_jbrowse2.log 2>&1
		fi
	fi

	if [[ ${bam_file} = *.bam ]]
	then
	        if [ -f "${params.outdir}/jbrowse2/${bam_file}" ]
        	then
                	echo "${params.outdir}/jbrowse2/${bam_file} already exists, do not add it to jborwse/" >& already_bam_jbrowse2.log 2>&1
        	else
			/opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} >& bam_jbrowse2.log 2>&1
			/opt/fix_symlink.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} ${bam_file}.bai >& fix_bam_symlink.log 2>&1
		fi
	fi
	        

        """
	



}

