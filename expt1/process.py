import numpy, pandas, sys
lambdaInName = 'out-lambda.csv'
lambdaOutName = 'processed-lambda.csv'
dockerInName = 'out-docker.csv'
dockerOutName = 'processed-docker.csv'

def quantile(arr, x):
    return round(arr.quantile(x), 2)

def remove_outlier(df, quantile_df, onColumn):
    quantile_df.drop(['duration'], axis=1, inplace=True)
    merged_df = df.merge(quantile_df, on=onColumn)
    merged_df.rename(index=str, inplace=True, columns={('ops', 'quantile-5'):'quantile-5', ('ops', 'quantile-95'): 'quantile-95'})
    merged_df = merged_df.loc[merged_df.ops > merged_df['quantile-5']]
    merged_df = merged_df.loc[merged_df.ops < merged_df['quantile-95']]
    merged_df.drop(['quantile-5', 'quantile-95'], axis=1, inplace=True)
    print(str(df.shape[0]) + '-' + str(merged_df.shape[0]) + ' = outliers:' + str(df.shape[0] - merged_df.shape[0]))
    return merged_df

def processed(inputName, outputName, attrName):
    try:
        data = pandas.read_csv(inputName)
        data.drop(['uuid', 'uptime'], axis=1, inplace=True)

        quantile_df = data.groupby(['bmName', attrName])[['ops','duration']].agg([
            ('quantile-5', lambda x: quantile(x, .05)), ('quantile-95', lambda x: quantile(x, .95))])

        # general = data.groupby(['bmName', attrName])[['ops','duration']].agg(['min', 'max', 'mean', 'std', 'count', 
        #     ('quantile-5', lambda x: quantile(x, .5)),('quantile-95', lambda x: quantile(x, .95))])

        clean_df = remove_outlier(data, quantile_df, attrName).groupby(['bmName', attrName])[['ops','duration']].agg(['min', 'max', 'mean', 'std', 'count'])
        clean_df.round(2).to_csv(outputName)

        print('output: ' + outputName)

    except Exception as error:
        print('Error:', error)

processed(lambdaInName, lambdaOutName, 'memory')
processed(dockerInName, dockerOutName, '#cpu')
