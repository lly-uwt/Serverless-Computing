const { exec } = require("child_process")
const { spawn } = require('child_process')
let infos
let timeup
let duration = 30000
let step = 500

exports.handler = (event, context, callback) => {
  infos = []
  timeup = false
  getInfo()

  setTimeout(() => {
    callback(null, infos)
    timeup = true
  }, duration) //(error, success)
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

function getInfo() {
  let count = 0
  const id = setInterval(() => {
    if (timeup) {
      clearInterval(id)
      return
    }
    let procsArr = []
    let ls = 'empty'
    exec('cp -a sysb/. /tmp/')
    exec('chmod +x /tmp/sysbench', () => {
      const lsProc = spawn('ls', ['/tmp'])
      lsProc.stdout.on('data', data => {
        ls = data.toString()
      })
      const procs = exec(
        'LD_LIBRARY_PATH=/tmp  /tmp/sysbench cpu --cpu-max-prime=200 run',
        (error, stdout, stderr) => {
          procsArr.push({ error: error })
          procsArr.push({ stdout: stdout })
          procsArr.push({ stderr: stderr })
          procsArr.push({ ls: ls })
        }
      )

      procs.on(
        "close",
        existCode => infos.push({ index: (count = count + 1), data: procsArr }),
        step
      )
    })
  })
}
