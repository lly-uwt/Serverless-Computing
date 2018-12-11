const fs = require('fs')
let newContainer = null
let cpuName = null
let uuid = null
const path = '/tmp/container-id'


exports.handler = (event, context, callback) => {
	getCpuName()
	newContainerCheck()
	const start = Date.now()
	const fibResult = fib(event.n)
	const time = Date.now() - start
	callback(null, {
		newContainer: newContainer,
		cpuName: cpuName,
		uuid: uuid,
		fibResult: fibResult,
		time: time
	})
}

exports.run = (n = 42, wantOutputFile) => {
	this.handler({ n: n }, null, (error, result) => {
		if (error) console.error(error)
		console.log(JSON.stringify(result))

		if (wantOutputFile)
			require('fs').writeFile('output.json', result, err => {
				if (err) console.error(err)
				console.log('output.json created')
			})
	})
}

// https://github.com/drujensen/fib/blob/master/fib.js
function fib(n) {
	if (n <= 1) return 1
	return fib(n - 1) + fib(n - 2)
}

function getCpuName() {
	const content = fs.readFileSync('/proc/cpuinfo', 'utf8')
	const start = content.indexOf('name') + 7
	const end = start + content.substring(start).indexOf('\n')
	cpuName = content.substring(start, end).trim()
}

function newContainerCheck() {
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