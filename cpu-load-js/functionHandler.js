const { spawn } = require('child_process')
let processes
let infos
let timeup
let newContainer = null
let uuid = null
const path = '/tmp/container-id'
const duration = 50000
const step = 1000

exports.handler = (event, context, callback) => {
  processes = []
  infos = []
  timeup = false

  newContainerCheck()
  spawnLoads(event.childNum)
  getInfo()

  setTimeout(() => {
    callback(null, infos)
    timeup = true
  }, duration) //(error, success)
}

exports.run = (childNum = 2, outputFileFlag = false) => {
  this.handler({ childNum: childNum }, null, (error, result) => {
    if (error) console.error(error)
    console.log(JSON.stringify(result))

    if (outputFileFlag)
      require('fs').writeFile('output.json', JSON.stringify(result), err => {
        if (err) console.error(err)
        console.log('output.json created')
      })
  })
}

// spawn child processes
function spawnLoads(childNum) {
  for (let i = 0; i < childNum; i++) {
    const procs = spawn('sha1sum', ['/dev/zero', '&'])
    processes.push(procs)
  }
}

function killLoads() {
  for (const child of processes) {
    child.kill('SIGINT')
  }
}

function getInfo() {
  let count = 0
  const id = setInterval(() => {
    if (timeup) {
      clearInterval(id)
      killLoads()
      return
    }
    let procsArr = [], totalPCPU = 0, cpu0 = 0, cpu1 = 0, nodeOverhead = 0
    const procs = spawn('ps', ['-o', 'pid,%cpu,cpuid,comm'])
    procs.stdout.on('data', data => {
      let str = data.toString()
      str = str.substring(str.indexOf('COMMAND') + 7).replace(/ +|\n/g, ' ').trim().replace(/ +/g, ' ').split(' ')

      for (let i = 0; i < str.length; i += 4) {
        totalPCPU += parseFloat(str[i + 1])
        if (str[i + 3] == 'node')
          nodeOverhead = parseFloat(str[i + 1])
        if (str[i + 2] == 0)
          cpu0 += parseFloat(str[i + 1])
        else
          cpu1 += parseFloat(str[i + 1])
        procsArr.push(`pid:${str[i]}-%cpu:${str[i + 1]}-cpuid:${str[i + 2]}-cmd:${str[i + 3]}`)
      }
    })

    procs.on('close', existCode => {
      infos.push({
        newContainer: newContainer,
        uuid: uuid,
        index: count = count + 1,
        data: procsArr.join(';'),
        cpu0: parseFloat(cpu0.toFixed(2)),
        cpu1: parseFloat(cpu1.toFixed(2)),
        totalPCPU: parseFloat(totalPCPU.toFixed(2)),
        overhead: nodeOverhead
      })
    })
  }, step)
}

function newContainerCheck() {
  const fs = require('fs')
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