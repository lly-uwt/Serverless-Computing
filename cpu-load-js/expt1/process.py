import numpy, pandas, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patheffects as path_effects

filename = 'out-docker-'
df = pandas.read_csv(filename + '.csv')

# take warm container
df = df.query("newContainer == 0")[['childs', '#cpu','uuid','indexBatch','processes','cpu0','cpu1','totalpcpu','overhead']]
df1 =  df.drop(['uuid', 'indexBatch', 'processes'], axis=1)
df1['cpu'] = df1['cpu0'] + df['cpu1']

df1.groupby(['#cpu'])[['cpu','cpu0','cpu1', 'overhead']].agg(['max', 'mean', 'std','count']).round(2).to_html(filename + '.html')