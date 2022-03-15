process jbrowse2_add_assembly {
        label 'jbrowse2'

        input:
        val(singularity_ok)
        path(fasta_file)
        path(fai_file)


        output:
        path("*.log"), emit: add_assembly_ok

        script:
        """

        if [ ! -d ${params.outdir}/jbrowse2 ]
        then
                mkdir ${params.outdir}/jbrowse2
        fi


	if [ -f "${params.outdir}/jbrowse2/${fasta_file}.fai" ]  
	then
    		echo "${params.outdir}/jbrowse2/${fasta_file}.fai already exists, do not add it to jborwse/" >& already_fasta_jbrowse2.log 2>&1
	else
		/opt/exec_jbrowse.sh ${params.outdir} ${fasta_file} >& fasta_jbrowse2.log 2>&1
	fi
		
	

        """

}

