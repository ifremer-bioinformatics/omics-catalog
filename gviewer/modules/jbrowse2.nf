process jbrowse2 {
        label 'jbrowse2'

        input:
	val(singularity_ok)
        file(fasta_file)
        file(bam_file)
        file(vcf_file)
        file(gff_file)
        file(gff3_file)

	file(fai_file)
	file(bai_file)
	file(vcf_gz_file)
	file(gff_gz_file)
	file(gff3_gz_file)

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
        	/opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${fasta_file} >& fasta_jbrowse2.log 2>&1
	fi

	if [[ ${bam_file} = *.bam ]]
	then
		/opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} >& bam_jbrowse2.log 2>&1
		/opt/fix_symlink.sh /opt/jbrowse2/${params.projectName}/${params.version} ${bam_file} ${bam_file}.bai >& fix_bam_symlink.log 2>&1
	fi
	        
	if [[ ${vcf_gz_file} = *.vcf.gz ]]
	then
        	/opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${vcf_gz_file} >& vcf_jbrowse2.log 2>&1
		/opt/fix_symlink.sh /opt/jbrowse2/${params.projectName}/${params.version} ${vcf_gz_file} ${vcf_gz_file}.tbi >& fix_vcf_symlink.log 2>&1
	fi

	if [[  ${gff_gz_file} = *.gff.gz ]]
	then
        	/opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${gff_gz_file} >& gff_jbrowse2.log 2>&1
		/opt/fix_symlink.sh /opt/jbrowse2/${params.projectName}/${params.version} ${gff_gz_file} ${gff_gz_file}.tbi >& fix_gff_symlink.log 2>&1
	fi

	if [[  ${gff3_gz_file} = *.gff3.gz ]]
	then
        	/opt/exec_jbrowse.sh /opt/jbrowse2/${params.projectName}/${params.version} ${gff3_gz_file} >& gff3_jbrowse2.log 2>&1
		/opt/fix_symlink.sh /opt/jbrowse2/${params.projectName}/${params.version} ${gff3_gz_file} ${gff3_gz_file}.tbi >& fix_gff3_symlink.log 2>&1
	fi

        """
	



}

