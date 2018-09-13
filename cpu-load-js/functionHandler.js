const { spawn } = require('child_process')
let processes
let infos
let timeup

exports.handler = (event, context, callback) => {
  processes = []
  infos = []
  timeup = false

  spawnLoads()
  getInfo()

  setTimeout(() => {
    callback(null, infos)
    timeup = true
  }, 5000) //(error, success)
}

exports.run = (wantOutputFile) => {
  this.handler(null, null, (error, result) => {
    if (error) console.error(error)
    console.log(JSON.stringify(result))

    if (wantOutputFile)
      require('fs').writeFile('output.json', result, err => {
        if (err) console.error(err)
        console.log('output.json created')
      })
  })
}

// spawn child processes
function spawnLoads() {
  for (let i = 0; i < 4; i++) {
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
    const procs = spawn('ps', ['-o', '%c%C'])
    procs.stdout.on('data', data => {
      let str = data.toString()
      str = str.replace('%CPU', '').replace('COMMAND', '').replace(/ +|\n/g, ' ').trim()
      str = str.split(' ')

      for (let i = 0; i < str.length; i += 2) {
        totalPCPU += parseInt(str[i + 1])
        procsArr.push(`${str[i]}:${str[i + 1]}` )
      }
    })

    procs.on('close', existCode => {
      infos.push({ index: count = count + 1, data: procsArr.join(';'), totalPCPU: totalPCPU })
    })
  }, 1000)
}