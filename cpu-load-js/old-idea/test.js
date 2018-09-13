const si = require('systeminformation')

si.processLoad('sha1sum',(data)=>{
    console.log(data)
})

si.services('sha1sum',(data)=>{
    console.log(data)
})

si.currentLoad((data)=>{
    console.log(data)
})

si.fullLoad((data)=>{
    console.log(data)
})