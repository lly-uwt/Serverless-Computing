import numpy, pandas, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt, mpld3

PRICE = 0.00001667
WORKLOAD = 100000

try:
    data = pandas.read_csv('data.csv')
    data = data.sort_values(by=['MemorySize'])
    data['cost100k'] = data.apply(lambda row: ((WORKLOAD * row.BilledDuration)/1000) * (row.MemorySize / 1024) * PRICE, axis=1)
    data.round(2).sort_values(by=['cost100k']).to_csv('totalcost-100000.csv')
    # print(data)
except Exception as error:
    print('Error:', error)