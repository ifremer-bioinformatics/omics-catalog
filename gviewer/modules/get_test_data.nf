process get_test_data {
    label 'internet_access'

    output:
    path("query.fna"), emit: query

    script:
    """
    get_test_data.sh ${baseDir} query.fna >& get_test_data.log 2>&1
    """
}

