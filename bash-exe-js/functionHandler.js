const { exec } = require("child_process")
let infos
let timeup
let duration = 5000
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
    const procs = exec(
      'bash -c "(sleep 1;echo 1) | TERM=xterm script -c top & sleep 2;killall script" | grep ^%Cpu',
      (error, stdout, stderr) => {
        procsArr.push({error: error})
        procsArr.push({stdout:stdout})
        procsArr.push({stderr: stderr})
      }
    )
    procs.on(
      "close",
      existCode => infos.push({ index: (count = count + 1), data: procsArr }),
      step
    )
  })
}
