import numpy, pandas, sys

# args = number of repeat

if(len(sys.argv) != 2):
    print('Invalid of number of args')
else:
    df = pandas.read_csv('all.csv')
    df.drop(['uuid', 'uptime'], axis=1, inplace=True)

    result = df.groupby(['bmName', '#cpu'])[['ops','duration']].agg(['min', 'max', 'mean', 'std'])
    result.round(2).to_csv(f'data-{sys.argv[1]}.csv')
