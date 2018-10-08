const { spawn } = require('child_process')
let processes
let infos
let timeup
let duration = 50000
let step = 1000
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
  let count = 0
  const id = setInterval(() => {
    if (timeup) {
      clearInterval(id)
      killLoads()
      return
    }
    let procsArr = [], totalPCPU = 0
    const procs = spawn('ps', ['-o', 'pid,%cpu,cpuid,comm'])
    procs.stdout.on('data', data => {
      let str = data.toString()
      str = str.substring(str.indexOf('COMMAND') + 7).replace(/ +|\n/g, ' ').trim().replace(/ +/g, ' ').split(' ')

      for (let i = 0; i < str.length; i += 5) {
        totalPCPU += parseFloat(str[i + 1])
        procsArr.push(`pid:${str[i]}-%cpu:${str[i + 1]}-cpuid:${str[i + 2]}-psr:${str[i + 3]}-cmd:${str[i + 4]}`)
      }
    })

    procs.on('close', existCode => {
      infos.push({ index: count = count + 1, data: procsArr.join(';'), totalPCPU: totalPCPU.toFixed(2) })
    })
  }, step)
}