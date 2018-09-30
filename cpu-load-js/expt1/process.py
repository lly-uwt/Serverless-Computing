import numpy, pandas, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt, mpld3

def readData(platform, fileType):
    outputMode = 'processed-%s-pspcpu.csv' % platform
    outputCpusDetail = 'processed-%s-CpusDetail.csv' % platform
    if(fileType == 'cpus'):
        return pandas.read_csv(outputCpusDetail)
    else:
        return  pandas.read_csv(outputMode, header=None)

def graph():

    data1 = readData('lambda', 'cpus')
    data2 = readData('docker', 'cpus')

    x1 = data1.iloc[3:,0].replace(',','.', regex=True).astype(float)
    y1cpu = data1.iloc[3:,3].replace(',','.', regex=True).astype(float)
    y1cpu0 = data1.iloc[3:,8].replace(',','.', regex=True).astype(float)
    y1cpu1 = data1.iloc[3:,13].replace(',','.', regex=True).astype(float)

    x2= data2.iloc[3:,0].replace(',','.', regex=True).astype(float)
    y2cpu = data2.iloc[3:,3].replace(',','.', regex=True).astype(float)
    y2cpu0 = data2.iloc[3:,8].replace(',','.', regex=True).astype(float)
    y2cpu1 = data2.iloc[3:,13].replace(',','.', regex=True).astype(float)
    
    fig, axes = plt.subplots(2, 2, figsize=(20,12))

    axes[0,0].set_xlabel('memory')
    axes[0,0].set_ylabel('percent')
    axes[0,0].set_title('Lambda, cpu0 -> red, cpu1 -> green, cpu -> blue')
    # cpu0 -> red, cpu1 -> green, cpu -> blue
    axes[0,0].plot(list(x1), list(y1cpu0), '-ro', list(x1), list(y1cpu1), '-go', list(x1), list(y1cpu), '-bo')
    axes[0,0].axis([0, 3050, 0, 100])

    axes[0,1].set_xlabel('memory')
    axes[0,1].set_ylabel('percent')
    axes[0,1].set_title('Docker, cpu0 -> red, cpu1 -> green, cpu -> blue')
    # cpu0 -> red, cpu1 -> green, cpu -> blue
    axes[0,1].plot(list(x2), list(y2cpu0), '-ro', list(x2), list(y2cpu1), '-go', list(x2), list(y2cpu), '-bo')
    axes[0,1].axis([0, 2.5, 0, 100])

    data3 = readData('lambda', 'pspcpu')
    data4 = readData('docker', 'pspcpu')

    x3 = data3[data3.columns[0]].replace(',','.', regex=True).astype(float)
    y3 = data3[data3.columns[1]].replace(',','.', regex=True).astype(float)

    x4 = data4[data4.columns[0]].replace(',','.', regex=True).astype(float)
    y4 = data4[data4.columns[1]].replace(',','.', regex=True).astype(float)

    axes[1,0].set_xlabel('memory')
    axes[1,0].set_ylabel('pcpu')
    axes[1,0].set_title('Lambda')
    axes[1,0].plot(list(x3), list(y3), '-bo')
    axes[1,0].axis([0, 3050, 0, 210])
    
    axes[1,1].set_xlabel('cpu')
    axes[1,1].set_ylabel('pcpu')
    axes[1,1].set_title('Docker')
    axes[1,1].plot(list(x4), list(y4), '-ro')
    axes[1,1].axis([0, 2.5, 0, 210])

    mpld3.save_html(fig,'figure1.html')
    print('figure1.html created!')

def processed(platform, attrName):
    inputName = 'out-%s-proc.csv' % platform
    ouputName = 'processed-%s-proc.csv' % platform
    outputMode = 'processed-%s-pspcpu.csv' % platform
    outputCpusDetail = 'processed-%s-CpusDetail.csv' % platform
    try:
        data = pandas.read_csv(inputName)

        # print(data.pivot_table(index=[ attrName], columns='cpuName', values='cpu%')) # output the mean?
        new = pandas.DataFrame(columns = [attrName,'indexBatch','cpu', 'cpu0', 'cpu1','totalPsPcpu'])
        cpu, cpu0, cpu1 = 0, 0, 0
        for index, row in data.iterrows():
            if(index % 3 == 0 and index != 0):
                new.loc[len(new)] = [row[attrName], row['indexBatch'], cpu, cpu0, cpu1, row['totalPsPcpu']]
            if(index % 5000 == 0):
                print('@Row ',index)
            if(row['cpuName'] == 'cpu0'):
                cpu0 = row['cpu%']
            elif(row['cpuName'] == 'cpu1'):
                cpu1 = row['cpu%']
            else:
                cpu = row['cpu%']
        
        new.to_csv(ouputName)

        # new = pandas.read_csv(ouputName) # test
        
        ps_pcpu_df = new[[attrName, 'totalPsPcpu']]
        ps_pcpu_df.groupby(attrName)['totalPsPcpu'].apply(lambda x: x.value_counts().head(1)).to_csv(outputMode)
        new.drop(['totalPsPcpu'], axis=1, inplace=True)
        new.groupby([attrName])[['cpu','cpu0','cpu1']].agg(['min', 'max', 'mean', 'std', 'count']).round(3).to_csv(outputCpusDetail)

        print(ouputName + ' created!')
        print(outputMode + ' created!')
        print(outputCpusDetail + ' created!')

    except Exception as error:
        print('Error:', error)

processed('lambda', '#memory')
processed('docker', '#cpu')

graph()