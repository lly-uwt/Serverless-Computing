const si = require("systeminformation")

exports.handler = (event, context, callback) => {



  //(error, success)
  callback(null, {})
}

exports.run = () => {
  this.handler(null, null, (error, result) => {
    if(error) console.error(error)
    console.log(result)
  })
}

// spawn child processes
function spawn(){

}


function getInfo() {
//   si.processes(data => {
//     console.log("CPU-Information:")
//     console.log(data.running)
//     for (let d of data.list) {
//       // console.log(d)
//       if (d.name == "sha1sum") console.log(d)
//     }
//   })

  si.processes(data => {
    console.log("CPU-Information:")
    for(const x of data.list)
        if(x.state == 'running')
            console.log(x)
  })
}


