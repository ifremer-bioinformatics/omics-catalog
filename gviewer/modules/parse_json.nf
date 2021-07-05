process parse_json {
        label 'parse_json'

	input:
	file(url_ok)

        output:
        path "parse_json.log"

        script:
        """
	parse_json.py -p ${params.genomesdir} -o ${params.catalogdir}/Genomes.csv >& parse_json.log 2>&1

        """

}

