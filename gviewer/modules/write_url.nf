process write_url {
        label 'url'

        input:
        file(adding_ok)

        output:
        path "write_url.log", emit : url_ok

        script:
        """
        write_url.py -p ${params.outdir} -u ${params.viewer_url} >& write_url.log 2>&1

        """

}

