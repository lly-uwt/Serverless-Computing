import numpy, pandas, sys

# args = number of repeat
try:
    df = pandas.read_csv('out-lambda.csv')
    df.drop(['uuid', 'uptime'], axis=1, inplace=True)

    result = df.groupby(['bmName','memory'])[['ops','duration']].agg(['min', 'max', 'mean', 'std'])
    result.round(2).to_csv('data-lambda.csv')
except Exception as error:
    print(error)

try:
    df = pandas.read_csv('out-docker.csv')
    df.drop(['uuid', 'uptime'], axis=1, inplace=True)

    result = df.groupby(['bmName','#cpu'])[['ops','duration']].agg(['min', 'max', 'mean', 'std'])
    result.round(2).to_csv('data-docker.csv')
except Exception as error:
    print(error)
