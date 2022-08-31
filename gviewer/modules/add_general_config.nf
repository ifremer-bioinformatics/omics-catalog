

process add_general_config {
        label 'add_general_config'

	input:
	val(add_assembly_ok)

        output:
        path "TESTconfig.json"

        script:
        """
	add_general_configuration.py --config_file ${params.outdir}/jbrowse2/config.json >& TESTconfig.json 2>&1

        """

}

