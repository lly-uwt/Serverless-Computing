const si = require('systeminformation')
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
    callback(null, JSON.stringify(infos))
    timeup = true
  }, 50000) //(error, success)
}

exports.run = () => {
  this.handler(null, null, (error, result) => {
    if (error) console.error(error)
    // console.log(result)

    require('fs').writeFile('output.json', result, err => {
      if (err) console.error(err)
      console.log('output.json created')
    })
  })
}

// spawn child processes
function spawnLoads() {
  si.cpu(cpuData => {
    for (let i = 0; i < 4; i++) {
      const procs = spawn('sha1sum', ['/dev/zero', '&'])
      processes.push(procs)
    }
  })
}

function killLoads() {
  for (const child of processes) {
    child.kill('SIGINT')
  }
}


function getInfo() {
  let count = 0
  const id = setInterval(() => {
    if (timeup) { clearInterval(id), killLoads() }
    si.processes(data => {
      // console.log('CPU-Information:')
      let runningProcs = []
      for (const x of data.list) {
        if (x.state == 'running') {
          runningProcs.push({ 
            pid: x.pid, name: x.name, 
            pcpu: x.pcpu, pcpuu:x.pcpus,
            pcpus: x.pcpus })
          // console.log(x)
        }
      }
      infos.push({ index: count = count + 1, data: runningProcs })
    })
  }, 2000)
}

function getInfoDetail() {
  let count = 0
  const id = setInterval(() => {
    if (timeup) { clearInterval(id), killLoads() }
    si.processes(data => {
      // console.log('CPU-Information:')
      let runningProcs = []
      for (const x of data.list) {
        if (x.state == 'running') {
          runningProcs.push(x)
          // console.log(x)
        }
      }
      infos.push({ index: count = count + 1, data: runningProcs })
    })
  }, 1000)
}
