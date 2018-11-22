memorySetting=($(seq 128 64 3008))
primeNumLimit=100000
loop=5
wloop=2
funcName=sysbench

# testing
# memorySetting=(128 256)
# primeNumLimit=200
# loop=1
# wloop=0
# funcName=sysbench

task(){
    output=`aws lambda invoke --function-name $funcName --payload '{"primeNumLimit":'$primeNumLimit'}' /dev/stdout | head -n 1 | head -c -2 ; echo`

    newContainer=`echo $output | jq -r '.newContainer'`
    cpuName=`echo $output | jq -r '.cpuName'`
    uuid=`echo $output | jq -r '.uuid'`
    threads=`echo $output | jq -r '.threads'`
    primeLimit=`echo $output | jq -r '.primeLimit'`
    speed=`echo $output| jq -r '.speed'`
    tt=`echo $output| jq -r '.general.totalTime'`
    te=`echo $output | jq -r '.general.totalEvent'`
    lateMin=`echo $output | jq -r '.latency.min'`
    lateAvg=`echo $output | jq -r '.latency.avg'`
    lateMax=`echo $output | jq -r '.latency.max'`
    late95th=`echo $output | jq -r '.latency."95th"'`
    lateSum=`echo $output | jq -r '.latency.sum'`
    fevent=`echo $output | jq -r '.fairness.events'`
    fexecTime=`echo $output | jq -r '.fairness.execTime'`

    echo $stamp,$1,$newContainer,$cpuName,$uuid,$threads,$primeLimit,$speed,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime
    echo $stamp,$1,$newContainer,$cpuName,$uuid,$threads,$primeLimit,$speed,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime >> sysbench-lambda.csv
}

stamp='P'$primeNumLimit'W'$wloop'L'$loop'T'`date +%Y%m%d%H%M%S`
echo 'stamp,memory,newContainer,cpuName,uuid,threads,primeLimit,speed,totalTime,totalEvent,lateMin,lateAvg,lateMax,late95th,lateSum,fevent,fexecTime' > sysbench-lambda.csv
for memory in ${memorySetting[@]}; do
    aws lambda update-function-configuration --function-name $funcName --memory-size $memory
    for ((x=0; x<$wloop; x++)); do
        aws lambda invoke --function-name $funcName --payload '{"primeNumLimit":'$primeNumLimit'}' /dev/stdout &
    done
    for ((i=0; i<$loop; i++)); do
       task $memory &
    done
done