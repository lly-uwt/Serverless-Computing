if [ ! -f subnets ]; then
    echo ERROR: File \'subnets\' not found
    exit 1
fi

subnets=(`cat subnets`)
currentSubnet=0
cpuTarget='Intel(R) Xeon(R) CPU E5-2666 v3 @ 2.90GHz'

consecutiveLimit=20
consecutiveCount=0

memorySetting=($(seq 128 64 3008))
primeNumLimit=100000
# remember add wloop
loop=3
funcName=sysbench

# testing
# memorySetting=(128 256)
# primeNumLimit=200
# loop=1
# funcName=sysbench

changeSubnet(){
    if [ $consecutiveCount = $consecutiveLimit ]; then
        echo ERROR: cpu target \'$cpuTarget\' not found. Please recheck the cpuName.
        exit 1
    fi
    
    aws lambda update-function-configuration --function-name $funcName --vpc-config SubnetIds=${subnets[$currentSubnet]}
    ((currentSubnet++))
    ((consecutiveCount++))
    if [ currentSubnet = ${#subnets[@]} ]; then
        currentSubnet=0
    fi
    echo $currentSubnet
}

stamp='P'$primeNumLimit'W'$wloop'L'$loop'T'`date +%Y%m%d%H%M%S`
echo 'stamp,memory,newContainer,cpuName,uuid,threads,primeLimit,speed,totalTime,totalEvent,lateMin,lateAvg,lateMax,late95th,lateSum,fevent,fexecTime' > sysbench-lambda.csv
for memory in ${memorySetting[@]}; do
    aws lambda update-function-configuration --function-name $funcName --memory-size $memory
    for ((i=0; i<$loop; i++)); do
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

        if [ "$cpuName" = "$cpuTarget" ]; then
            consecutiveCount=0
            echo $stamp,$memory,$newContainer,$cpuName,$uuid,$threads,$primeLimit,$speed,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime
            echo $stamp,$memory,$newContainer,$cpuName,$uuid,$threads,$primeLimit,$speed,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime >> sysbench-lambda.csv
        else
            echo $cpuName != $cpuTarget
            changeSubnet
            ((i--))
        fi
    done
done