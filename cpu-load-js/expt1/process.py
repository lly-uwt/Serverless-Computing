import numpy, pandas, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt, mpld3

lambdaInName = 'out-lambda.csv'
lambdaOutName = 'processed-lambda.csv'
lambdaOutModeName = 'processed-lambda-mode.csv'
lambdaVLOutName = 'processed-lambda-vl.txt'
dockerInName = 'out-docker.csv'
dockerOutName = 'processed-docker.csv'
dockerOutModeName = 'processed-docker-mode.csv'
dockerVLOutName = 'processed-docker-vl.txt'

def graph():
    data1 = pandas.read_csv(lambdaOutModeName, header=None)
    data2 = pandas.read_csv(dockerOutModeName, header=None)
    # print(data1)
    x = data1[data1.columns[0]].replace(',','.', regex=True).astype(float)
    y = data1[data1.columns[1]].replace(',','.', regex=True).astype(float)

    x2 = data2[data2.columns[0]].replace(',','.', regex=True).astype(float)
    y2 = data2[data2.columns[1]].replace(',','.', regex=True).astype(float)
 
    fig, axes = plt.subplots(1, 2, figsize=(20,8))

    axes[0].set_xlabel('memory')
    axes[0].set_ylabel('pcpu')
    axes[0].set_title('Lambda')
    axes[0].plot(list(x), list(y), '-bo')
    axes[0].axis([0, 3050, 0, 210])
    
    axes[1].set_xlabel('cpu')
    axes[1].set_ylabel('pcpu')
    axes[1].set_title('Docker')
    axes[1].plot(list(x2), list(y2), '-ro')
    axes[1].axis([0, 2.5, 0, 210])

    mpld3.save_html(fig,'figure1.html')
    print('figure1.html created!')

def processed(inputName, optName, optMName, optVLname, attrName):
    try:
        data = pandas.read_csv(inputName)
        data.drop(['processes', 'indexBatch'], axis=1, inplace=True)
        data.totalpcpu = data.totalpcpu.round(0)

        data1 = data.groupby([attrName]).totalpcpu.value_counts()
        data1.to_csv(optName)
        data1.to_string(optVLname)
        data2 = data.groupby(attrName)['totalpcpu'].apply(lambda x: x.value_counts().head(1))
        data2.to_csv(optMName)

        print(optName + ' created!')
        print(optVLname + ' created!')
        print(optMName + ' created!')
        graph()

    except Exception as error:
        print('Error:', error)

processed(lambdaInName, lambdaOutName, lambdaOutModeName, lambdaVLOutName, 'memory')
processed(dockerInName, dockerOutName, dockerOutModeName, dockerVLOutName, '#cpu')

graph()
