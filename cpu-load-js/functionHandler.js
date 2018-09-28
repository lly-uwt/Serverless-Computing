const { spawn } = require('child_process')
const { exec } = require('child_process')
const fs = require('fs')
let processes
let infos
let timeup
let duration = 50000
let childNum = 4

exports.handler = (event, context, callback) => {
  processes = []
  infos = []
  timeup = false

  spawnLoads()
  getInfo()

  setTimeout(() => {
    callback(null, infos)
    timeup = true
  }, duration) //(error, success)
}

exports.run = (wantOutputFile) => {
  this.handler(null, null, (error, result) => {
    if (error) console.error(error)
    console.log(JSON.stringify(result))

    if (wantOutputFile)
      require('fs').writeFile('output.json', JSON.stringify(result), err => {
        if (err) console.error(err)
        console.log('output.json created')
      })
  })
}

// spawn child processes
function spawnLoads() {
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
  let prev = null, count = 0
  const id = setInterval(async () => {
    if (timeup) {
      clearInterval(id)
      killLoads()
      return
    }

    let now = readProcStat()
    if (prev) {
      let data = []
      for (let x = 0; x < prev.length; x++) {
        let idle = now[x].idle - prev[x].idle
        let total = now[x].total - prev[x].total
        data.push({ name: prev[x].name, '%': ((1 - idle / total) * 100).toFixed(2) })
      }
      let psData = await getPsData()
      infos.push({ index: count = count + 1, cpudata: data, psdata: psData })
    }
    prev = now

  }, 1000)
}

function getPsData() {
  return new Promise(resolve => {
    let procsArr = [], totalPCPU = 0
    exec('ps -o pid,%cpu,cpuid,psr,comm', (error, stdout, stderr) => {
      let str = stdout
      str = str.substring(str.indexOf('COMMAND') + 7).replace(/ +|\n/g, ' ').trim().replace(/ +/g, ' ').split(' ')

      for (let i = 0; i < str.length; i += 5) {
        totalPCPU += parseFloat(str[i + 1])
        procsArr.push({ pid: str[i], 'pcpu': str[i + 1], cpuid: str[i + 2], psr: str[i + 3], cmd: str[i + 4] })
      }
      resolve({ ps: procsArr, totalcpu: totalPCPU.toFixed(2) })
    })
  })
}

function readProcStat() {
  let info = []
  let contents = fs.readFileSync('/proc/stat', 'utf8')

  let lines = contents.substring(0, contents.indexOf('intr')).trim().split('\n')
  for (const line of lines) {
    let array = line.replace('  ', ' ').split(' ')

    let x = 1, total = 0
    while (x < array.length) {
      total += parseInt(array[x])
      x += 1
    }
    let pIlde = parseInt(array[4])
    info.push({ name: array[0], idle: pIlde, total: total })
  }
  return info
}

