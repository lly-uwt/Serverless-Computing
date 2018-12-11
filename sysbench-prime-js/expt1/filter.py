import numpy, pandas, sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patheffects as path_effects

target = "Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz"
filename = 'sysbench-lambda-p2'
df = pandas.read_csv(filename + '.csv')

# take warm container
df = df.query("newContainer == 0")[['stamp','memory','cpuName','speed','totalTime','totalEvent',
                                    'lateMin','lateAvg','lateMax','late95th', 'lateSum', 
                                    'fevent', 'fexecTime']]
df = df.query("cpuName ==  '" + target + "'")[['stamp','memory','cpuName','speed','totalTime','totalEvent',
                                    'lateMin','lateAvg','lateMax','late95th', 'lateSum', 
                                    'fevent', 'fexecTime']]
df.to_csv(filename + '-filter.csv')

df.groupby(['memory'])[['speed','totalEvent']].agg(['max','mean','std','count']).round(2).to_html(filename + '.html')





