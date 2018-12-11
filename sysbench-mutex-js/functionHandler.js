const { exec } = require('child_process')
const fs = require('fs')
let newContainer = null
let cpuName = null
let uuid = null
const path = '/tmp/container-id'
const cmd = 'sysbench mutex --mutex-num=1 --mutex-locks=20000000 --mutex-loops=1 --threads=2 run'

exports.handler = (event, context, callback) => {
  newContainerCheck()
  getCpuName()
  let procsArr = {}
  exec('cp -a sysb/. /tmp/', () => {
    exec('chmod +x /tmp/sysbench', () => {
      const procs = exec(
        `LD_LIBRARY_PATH=/tmp  /tmp/${cmd}`,
        (error, stdout, stderr) => {
          procsArr.error = error
          procsArr.stdout = stdout
          procsArr.stderr = stderr
        }
      )
      procs.on('close', existCode => callback(null, getStatsPrimeTest(procsArr.stdout)))
    })
  })
}

function getStatsPrimeTest(output) {
  const value = getValue(output,
    [
      'Number of threads:',
      'total time:', 'total number of events:',
      'min:', 'avg:', 'max:', '95th percentile:', 'sum:',
      'events (avg/stddev):', 'execution time (avg/stddev):'
    ]
  )


  return {
    newContainer: newContainer,
    cpuName: cpuName,
    uuid: uuid,
    sysbVer: output.substring(0, output.indexOf('\n')).trim(),
    cmd: cmd,
    threads: parseInt(value[0]),
    general: {
      totalTime: parseFloat(value[1]),
      totalEvent: parseInt(value[2])
    },
    latency: {
      min: parseFloat(value[3]),
      avg: parseFloat(value[4]),
      max: parseFloat(value[5]),
      '95th': parseFloat(value[6]),
      sum: parseFloat(value[7])
    },
    fairness: {
      events: value[8],
      execTime: value[9]
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

exports.run = (wantOutputFile) => {
  this.handler({}, null, (error, result) => {
    if (error) console.error(error)
    console.log(JSON.stringify(result))

    if (wantOutputFile)
      require('fs').writeFile('output.json', result, err => {
        if (err) console.error(err)
        console.log('output.json created')
      })
  })
}

function getCpuName() {
  const content = fs.readFileSync('/proc/cpuinfo', 'utf8')
  const start = content.indexOf('name') + 7
  const end = start + content.substring(start).indexOf('\n')
  cpuName = content.substring(start, end).trim()
}

function newContainerCheck() {
  fs.open(path, 'r+', (err, fd) => {
    if (err) { // not there
      const containerId = generateUUID()
      fs.writeFile(path, containerId, () => {
        newContainer = 1
        uuid = containerId
      })
    }
    else {
      fs.readFile(path, (err, data) => {
        newContainer = 0
        uuid = data.toString('utf8')
      })
    }
  })
}

// https://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
function generateUUID() {
  let d = new Date().getTime()
  if (Date.now) {
    d = Date.now()
  }
  const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    const r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor(d / 16)
    return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16)
  })
  return uuid
}