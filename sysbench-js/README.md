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
    "primeLimit": 200,
    "threads": 2,
    "speed": 453916.86,
    "general": {
        "totalTime": 10.0001,
        "totalEvent": 4539933
    },
    "latency":{
        "min": 0.00,
        "avg": 0.00,
        "max": 24.02,
        "95th": 0.00,
        "sum": 19033.98
    },
    "fairness": {
        "events": "2269966.5000/11439.50",
        "execTime": "9.5170/0.01"
    }
}
```