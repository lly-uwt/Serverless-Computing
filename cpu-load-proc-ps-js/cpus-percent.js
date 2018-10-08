const fs = require('fs')

run()

function run() {
  let prev = null
  setInterval(() => {
    let fs = require('fs')
    now = readProcStat()
    if (prev) {
      for(let x = 0; x < prev.length; x++) {
        let idle  =  now[x].idle - prev[x].idle
        let total = now[x].total - prev[x].total
        console.log(`${prev[x].name}:${((1-idle/total)*100).toFixed(2)}`)
      }
      console.log()
    }
    prev = now
  }, 1000)
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