import numpy, pandas, sys
lambdaInName = 'out-lambda.csv'
lambdaOutName = 'processed-lambda.csv'
dockerInName = 'out-docker.csv'
dockerOutName = 'processed-docker.csv'

def processed(inputName, outputName, attrName):
    try:
        data = pandas.read_csv(inputName)
        data.drop(['processes', 'indexBatch'], axis=1, inplace=True)

        data = data.groupby([attrName]).totalpcpu.value_counts()

        data.to_string(outputName)

        print('output: ' + outputName)

    except Exception as error:
        print('Error:', error)

processed(lambdaInName, lambdaOutName, 'memory')
processed(dockerInName, dockerOutName, '#cpu')