#!/usr/bin/env nextflow

/*
========================================================================================
                                    GENOMEBROWSER workflow                                     
========================================================================================
 Workflow for Genomebrowser.
 #### Homepage / Documentation
 https://gitlab.ifremer.fr/bioinfo/genomebrowser
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl=2
import groovy.json.JsonSlurper

/*
 * SET UP CONFIGURATION VARIABLES
 */

//Copy config files to output directory for each run
paramsfile = file("$baseDir/conf/base.config", checkIfExists: true)
paramsfile.copyTo("$params.logdir/00_pipeline_conf/base.config")

if (workflow.profile.contains('custom')) {
   customparamsfile = file("$baseDir/conf/custom.config", checkIfExists: true)
   customparamsfile.copyTo("$params.logdir/00_pipeline_conf/custom.config")
}

log.info SeBiMERHeader()
def summary = [:]
log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[91m--------------------------------------------------\033[0m-"



/*
 * VERIFY AND SET UP WORKFLOW VARIABLES
 */

include { index_fasta } from './modules/fasta.nf'
include { index_bam } from './modules/bam.nf'
include { index_vcf } from './modules/vcf.nf'
include { index_gff } from './modules/gff.nf'
include { index_gff3 } from './modules/gff3.nf'
include { jbrowse2 } from './modules/jbrowse2.nf'
include { write_url } from './modules/write_url.nf'
include { get_singularity_images } from './modules/get_singularity_images.nf'
include { parse_json } from './modules/parse_json.nf'

if (workflow.profile.contains('custom')) {

        if (!params.fasta.isEmpty()) {
                channel
                  .fromPath( params.fasta )
                  .ifEmpty { error "Cannot find any fasta file matching: ${params.fasta}" }
                  .set { fasta_file }
        }
        else {
                fasta_file=channel.value('0')
        }

        if (!params.bam.isEmpty()) {
                channel
                 .fromPath( params.bam )
                 .ifEmpty { error "Cannot find any bam file matching: ${params.bam}" }
                 .set { bam_file }
        }
        else {
                bam_file=channel.value('0')
        }

        if (!params.vcf.isEmpty()) {
                channel
                 .fromPath( params.vcf )
                 .ifEmpty { error "Cannot find any vcf file matching: ${params.vcf}" }
                 .set { vcf_file }
        }
        else {
                vcf_file=channel.value('0')
        }

        if (!params.gff.isEmpty()) {
                channel
                 .fromPath( params.gff )
                 .ifEmpty { error "Cannot find any gff file matching: ${params.gff}" }
                 .set { gff_file }
        }
        else {
                gff_file=channel.value('0')
        }

        if (!params.gff3.isEmpty()) {
                channel
                 .fromPath( params.gff3 )
                 .ifEmpty { error "Cannot find any gff3 file matching: ${params.gff3}" }
                 .set { gff3_file }
        }
        else {
                gff3_file=channel.value('0')
        }
	
        channel
         .fromPath( params.config_json )
         .ifEmpty { error "Cannot find any json file matching: ${params.config_json}" }
	
        channel
         .fromPath( params.databank_json )
         .ifEmpty { error "Cannot find any json file matching: ${params.databank_json}" }

	channel
	 .fromPath( 'catalog_file' )
	 .set { catalog_file }

}

/*
 * CHECK CONFIG.JSON FILE PRESENCE IN DATA DIRECTORY
 */

// Config.json file is automatically created if it doesn't exist

def FileJSON = new File("${params.config_json}")
if (FileJSON.exists()){

/*
 * CHECK ASSEMBLY PRESENCE IN CONFIG.JSON
 */

	def jsonSlurper = new JsonSlurper()

	// Load the text from the JSON
	String ConfigJSON = FileJSON.text

	// Create a dictionary object from the JSON text
	def myConfig = jsonSlurper.parseText(ConfigJSON)

	// Access values in the dict
	assembly_presence =  myConfig.assemblies
}
else {

	assembly_presence = '[]'
}

/*
 * CHECK JBROWSE URL PRESENCE IN DATABANK.JSON
 */

        def jsonSlurper = new JsonSlurper()

        // New File object from your JSON file
        def File2JSON = new File("${params.databank_json}")

        // Load the text from the JSON
        String DatabankJSON = File2JSON.text

        // Create a dictionary object from the JSON text
        def myConfig = jsonSlurper.parseText(DatabankJSON)

        // Access values in the dict
        url_presence =  myConfig.jbrowse.JBROWSE
        println url_presence


/*
 * RUN MAIN WORKFLOW
 */

workflow {

	if (params.catalog_only) {
		
	//	touch catalog_file 
		parse_json(catalog_file)

	}
	else if  (!(assembly_presence.isEmpty()) || !(fasta_file.isEmpty())){
	
		get_singularity_images()
	
		if (!params.fasta.isEmpty()) {
			index_fasta(fasta_file, get_singularity_images.out.singularity_ok)
			fai_file=index_fasta.out.fai_file
		}
		 else {
			fai_file=channel.value('0')
		}

		if (!params.bam.isEmpty()) {
			index_bam(bam_file, get_singularity_images.out.singularity_ok)
			bai_file=index_bam.out.bai_file
		}
		else {
			bai_file=channel.value('0')
		}

		if (!params.vcf.isEmpty()) {
			index_vcf(vcf_file, get_singularity_images.out.singularity_ok)
			vcf_gz_file=index_vcf.out.vcf_gz_file
		}
		else {
			vcf_gz_file=channel.value('0')
		}

		if (!params.gff.isEmpty()) {
			index_gff(gff_file, get_singularity_images.out.singularity_ok)
			gff_gz_file=index_gff.out.gff_gz_file
		}
		else {
			gff_gz_file=channel.value('0')
		}
		
		if (!params.gff3.isEmpty()) {
			index_gff3(gff3_file, get_singularity_images.out.singularity_ok)
			gff3_gz_file=index_gff3.out.gff3_gz_file
		}
		else {
			gff3_gz_file=channel.value('0')
		} 

		jbrowse2(get_singularity_images.out.singularity_ok, fasta_file, bam_file, vcf_file, gff_file, gff3_file, fai_file, bai_file, vcf_gz_file, gff_gz_file, gff3_gz_file)
				
		if (url_presence.isEmpty()){
			write_url(jbrowse2.out.adding_ok)
			parse_json(write_url.out.url_ok)
		}
	}
	else {
		println "Please, indicate a fasta file"
	}

}

def SeBiMERHeader() {
    // Log colors ANSI codes
    c_red = params.monochrome_logs ? '' : "\033[0;91m";
    c_blue = params.monochrome_logs ? '' : "\033[1;94m";
    c_reset = params.monochrome_logs ? '' : "\033[0m";
    c_yellow = params.monochrome_logs ? '' : "\033[1;93m";
    c_Ipurple = params.monochrome_logs ? '' : "\033[0;95m" ;

    return """    -${c_red}--------------------------------------------------${c_reset}-
    ${c_blue}    __  __  __  .       __  __  ${c_reset}
    ${c_blue}   \\   |_  |__) | |\\/| |_  |__)  ${c_reset}
    ${c_blue}  __\\  |__ |__) | |  | |__ |  \\  ${c_reset}
                                            ${c_reset}
    ${c_yellow}  OMICS-CATALOG workflow (version ${workflow.manifest.version})${c_reset}
                                            ${c_reset}
    ${c_Ipurple}  Homepage: ${workflow.manifest.homePage}${c_reset}
    -${c_red}--------------------------------------------------${c_reset}-
    """.stripIndent()
}

