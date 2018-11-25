import numpy, pandas, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patheffects as path_effects

file1 = 'sysbench-lambda-p1-filter'
file2 = 'sysbench-lambda-p2-filter'
df1 = pandas.read_csv(file1 + '.csv')
df2 = pandas.read_csv(file2 + '.csv')

df = df1.append(df2)

df.groupby(['memory'])[['speed','totalEvent']].agg(['max','mean','std','count']).round(2).to_html('combined.html')