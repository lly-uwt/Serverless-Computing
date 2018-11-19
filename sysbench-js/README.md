run js `node -e 'require("./functionHandler").run()'`

#### `sysbench cpu --cpu-max-prime=200 --threads=2`
Example console output version:
```
Running the test with following options:
Number of threads: 2
Initializing random number generator from current time


Prime numbers limit: 200

Initializing worker threads...

Threads started!

CPU speed:
    events per second: 453916.86

General statistics:
    total time:                          10.0001s
    total number of events:              4539933

Latency (ms):
         min:                                  0.00
         avg:                                  0.00
         max:                                 24.02
         95th percentile:                      0.00
         sum:                              19033.98

Threads fairness:
    events (avg/stddev):           2269966.5000/11439.50
    execution time (avg/stddev):   9.5170/0.01
```

Example JSON version:
```json
{
  "newContainer": 1,
  "cpuName": "Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz",
  "uuid": "6beb0f53-8056-4b6c-adc0-e96f17aae99f",
  "threads": 2,
  "primeLimit": 200,
  "speed": 15424.73,
  "general": {
    "totalTime": 10.06,
    "totalEvent": 155198
  },
  "latency": {
    "min": 0,
    "avg": 0.13,
    "max": 416.12,
    "95th": 0.01,
    "sum": 19886.44
  },
  "fairness": {
    "events": "77599.0000/13715.00",
    "execTime": "9.9432/0.05"
  }
}
```