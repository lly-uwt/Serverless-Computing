
exports.handler = (event, context, callback) => {
  let totalPrimeCount = 0
  for (let i = 0; i <= event.max; i++) {
    if(isPrime(i))
      totalPrimeCount = totalPrimeCount + 1
  }
  //(error, success)
  callback(null, `Total prime numbers counted: ${totalPrimeCount}`)

  function isPrime(num) {
    if (num < 2) return false
    for (let i = 2; i < num; i++) {
      if (num % i == 0)
        return false
    }
    return true
  }
}