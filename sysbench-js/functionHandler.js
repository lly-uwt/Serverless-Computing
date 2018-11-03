const { exec } = require("child_process")

exports.handler = (event, context, callback) => {
  let procsArr = {}
  exec('cp -a sysb/. /tmp/', () => {
    exec('chmod +x /tmp/sysbench', () => {
      const procs = exec(
        'LD_LIBRARY_PATH=/tmp  /tmp/sysbench cpu --cpu-max-prime=200 --threads=2 run',
        (error, stdout, stderr) => {
          procsArr.error = error
          procsArr.stdout = stdout
          procsArr.stderr = stderr
        }
      )
      procs.on("close", existCode => callback(null, getStatsPrimeTest(procsArr.stdout)))
    })
  })
}

function getStatsPrimeTest(output) {
  let value = getValue(output,
    [
      'Number of threads:',
      'Prime numbers limit:',
      'events per second:',
      'total time:', 'total number of events:',
      'min:', 'avg:', 'max:', '95th percentile:', 'sum:',
      'events (avg/stddev):', 'execution time (avg/stddev):'
    ]
  )

  return {
    "threads": parseInt(value[0]),
    "primeLimit": parseInt(value[1]),
    "speed": parseFloat(value[2]),
    "general": {
      "totalTime": parseFloat(value[3]),
      "totalEvent": parseInt(value[4])
    },
    "latency": {
      "min": parseFloat(value[5]),
      "avg": parseFloat(value[6]),
      "max": parseFloat(value[7]),
      "95th": parseFloat(value[8]),
      "sum": parseFloat(value[9])
    },
    "fairness": {
      "events": value[10],
      "execTime": value[11]
    }
  }

  function getValue(output, array) {
    const outArr = []
    for (const x of array) {
      const substr = output.substring(output.indexOf(x) + x.length + 1)
      outArr.push(substr.substring(0, substr.indexOf('\n')).trim())
    }
    return outArr
  }
}

exports.run = wantOutputFile => {
  this.handler(null, null, (error, result) => {
    if (error) console.error(error)
    console.log(JSON.stringify(result))

    if (wantOutputFile)
      require("fs").writeFile("output.json", result, err => {
        if (err) console.error(err)
        console.log("output.json created")
      })
  })
}