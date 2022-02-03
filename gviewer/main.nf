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

def helpMessage() {
    // Add to this help message with new command line parameters
    log.info SeBiMERHeader()
    log.info"""

    Usage:

    The typical command for running the pipeline after filling the conf/custom.config file is as follows:

	nextflow run main.nf -profile custom,singularity

	Mandatory arguments:
	-profile [str]			Configuration profile to use. Can use multiple (comma separated). Available: test, custom, singularity.
	--projectName [str]		Name of the organism that will be added to the catalog.
	--version [str]		        Name of the genome version.

	Generic:
	--genomesdir [path]		Path to the genomes directory, where each organism directory is located. (default = /dataset/custom/genomes) 
	--outdir [path		        Path to the data directory, where the omics files are located. This path must lead to the organism version directory. (default = /dataset/custom/genomes/${projectName}/${version})
	--catalogdir [path]		Path where the Genomes.csv file will be generated. (default = /dataset/custom/catalog)
	--logdir [path]			Path to the log directory, where the log files will be publised. (default = /work)

	Running only the catalog:
	--catalog_only [bool]		Active only the catalog. No jbrowse2 session will be created. (default = false)

	Omics data type:
	--fasta [path]			Path to the reference sequence of the organism. Can be FASTA or FNA format.
	--bam [path]			Path to the alignement file of the organism.
	--vcf [path]			Path to the variant calling file of the organism.
	--gff [path]			Path to the annotation file of the organism, in gff format.
	--gff3 [path]			Path to the annotation file of the organism, in gff3 format. 

	""".stripIndent()
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

//Copy config files to output directory for each run
paramsfile = file("$baseDir/conf/base.config", checkIfExists: true)
paramsfile.copyTo("$params.logdir/00_pipeline_conf/base.config")

if (workflow.profile.contains('test')) {
   testparamsfile = file("$baseDir/conf/test.config", checkIfExists: true)
   testparamsfile.copyTo("$params.logdir/00_pipeline_conf/test.config")
}

if (workflow.profile.contains('custom')) {
   customparamsfile = file("$baseDir/conf/custom.config", checkIfExists: true)
   customparamsfile.copyTo("$params.logdir/00_pipeline_conf/custom.config")
}

log.info SeBiMERHeader()
def summary = [:]
if (workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Profile'] = workflow.profile
summary['Project Name'] = params.projectName
summary['Version'] = params.version
summary['Genomes directory'] = params.genomesdir
summary['Output dir'] = params.outdir
summary['Catalog dir'] = params.catalogdir
summary['FASTA File'] = params.fasta
summary['BAM File'] = params.bam
summary['VCF File'] = params.vcf
summary['GFF File'] = params.gff
summary['GFF3 File'] = params.gff3


log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[91m--------------------------------------------------\033[0m-"

// Check the hostnames against configured profiles
checkHostname()


/*
 * VERIFY AND SET UP WORKFLOW VARIABLES
 */

include { get_test_data } from './modules/get_test_data.nf'
include { index_fasta } from './modules/fasta.nf'
include { jbrowse2_add_assembly } from './modules/jbrowse2_add_assembly.nf'
include { index_bam } from './modules/bam.nf'
include { jbrowse2_bam } from './modules/jbrowse2_bam.nf'

include { index_vcf } from './modules/vcf.nf'
include { jbrowse2_vcf } from './modules/jbrowse2_vcf.nf'

include { index_gff } from './modules/gff.nf'
include { jbrowse2_gff } from './modules/jbrowse2_gff.nf'

include { index_gff3 } from './modules/gff3.nf'
include { jbrowse2_gff3 } from './modules/jbrowse2_gff3.nf'

// include { jbrowse2 } from './modules/jbrowse2.nf'
include { write_url } from './modules/write_url.nf'
include { get_singularity_images } from './modules/get_singularity_images.nf'
include { parse_json } from './modules/parse_json.nf'


if (!params.fasta.isEmpty() && !workflow.profile.contains('test')) {
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

if (params.config_json.isEmpty()) {
 	log.error "Cannot find any json file matching: ${params.config_json}"
	exit 1
}

if (params.databank_json.isEmpty()) {
	log.error "Cannot find any json file matching: ${params.databank_json}"
	exit 1
}

channel
 .fromPath( 'catalog_file' )
 .set { catalog_file }


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


def File2JSON = new File("${params.databank_json}")
if (File2JSON.exists()){

	def json2Slurper = new JsonSlurper()

	// Load the text from the JSON
	String DatabankJSON = File2JSON.text

	// Create a dictionary object from the JSON text
	def myConfig = json2Slurper.parseText(DatabankJSON)

	// Access values in the dict
	url_presence =  myConfig.jbrowse.JBROWSE
}
else {
	url_presence = ""
}

/*
 * RUN MAIN WORKFLOW
 */

workflow {

	if (workflow.profile.contains('test')) {
		get_test_data()
		fasta_file = get_test_data.out.query

	}
	if (params.catalog_only) {
		parse_json(catalog_file)
	}
	else if  (!(assembly_presence.isEmpty()) || !(fasta_file.isEmpty())){
		get_singularity_images()
	
		if (!params.fasta.isEmpty()) {
			index_fasta(fasta_file, get_singularity_images.out.singularity_ok)
			fai_file=index_fasta.out.fai_file
			jbrowse2_add_assembly(get_singularity_images.out.singularity_ok, fasta_file, fai_file)
		}
		else {
			fai_file=channel.value('0')
		}
		if (!params.bam.isEmpty() ) {
			index_bam(bam_file, get_singularity_images.out.singularity_ok)
			bai_file=index_bam.out.bai_file
			jbrowse2_bam(bam_file, bai_file, get_singularity_images.out.singularity_ok)
		}
		else {
			bai_file=channel.value('0')
		}

		if (!params.vcf.isEmpty()) {
			index_vcf(vcf_file, get_singularity_images.out.singularity_ok)
			vcf_gz_file=index_vcf.out.vcf_gz_file
			jbrowse2_vcf(vcf_file, vcf_gz_file, get_singularity_images.out.singularity_ok)
		}
		else {
			vcf_gz_file=channel.value('0')
		}

		if (!params.gff.isEmpty()) {
			index_gff(gff_file, get_singularity_images.out.singularity_ok)
			gff_gz_file=index_gff.out.gff_gz_file
			jbrowse2_gff(gff_file, gff_gz_file, get_singularity_images.out.singularity_ok)
		}
		else {
			gff_gz_file=channel.value('0')
		}
		
		if (!params.gff3.isEmpty()) {
			index_gff3(gff3_file, get_singularity_images.out.singularity_ok)
			gff3_gz_file=index_gff3.out.gff3_gz_file
			jbrowse2_gff3(gff3_file, gff3_gz_file, get_singularity_images.out.singularity_ok)
		}
		else {
			gff3_gz_file=channel.value('0')
		} 

		// jbrowse2(get_singularity_images.out.singularity_ok, fasta_file, bam_file, vcf_file, gff_file, gff3_file, fai_file, bai_file, vcf_gz_file, gff_gz_file, gff3_gz_file)
				
		if (url_presence.isEmpty()){
			//write_url(jbrowse2.out.adding_ok)
			write_url(jbrowse2_add_assembly.out.add_assembly_ok)
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

def checkHostname() {
    def c_reset = params.monochrome_logs ? '' : "\033[0m"
    def c_white = params.monochrome_logs ? '' : "\033[0;37m"
    def c_red = params.monochrome_logs ? '' : "\033[1;91m"
    def c_yellow_bold = params.monochrome_logs ? '' : "\033[1;93m"
    if (params.hostnames) {
        def hostname = "hostname".execute().text.trim()
        params.hostnames.each { prof, hnames ->
            hnames.each { hname ->
                if (hostname.contains(hname) && !workflow.profile.contains(prof)) {
                    log.error "====================================================\n" +
                            "  ${c_red}WARNING!${c_reset} You are running with `-profile $workflow.profile`\n" +
                            "  but your machine hostname is ${c_white}'$hostname'${c_reset}\n" +
                            "  ${c_yellow_bold}It's highly recommended that you use `-profile $prof${c_reset}`\n" +
                            "============================================================"
                }
            }
        }
    }
}

