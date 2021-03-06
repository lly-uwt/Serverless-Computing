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
# loop = loop + wloop
loop=105
funcName=sysbench-mutex

# testing
# memorySetting=(128 256)
# loop=1
# funcName=sysbench-mutex

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
    echo $currentSubnet-${subnets[$currentSubnet]}
}

stamp='L'$loop'T'`date +%Y%m%d%H%M%S`'S'
echo 'stamp,memory,newContainer,cpuName,uuid,sysbVer,cmd,threads,totalTime,totalEvent,lateMin,lateAvg,lateMax,late95th,lateSum,fevent,fexecTime' > sysbench-lambda.csv
for memory in ${memorySetting[@]}; do
    aws lambda update-function-configuration --function-name $funcName --memory-size $memory
    for ((i=0; i<$loop; i++)); do
        output=`aws lambda invoke --function-name $funcName /dev/stdout | head -n 1 | head -c -2 ; echo`

        newContainer=`echo $output | jq -r '.newContainer'`
        cpuName=`echo $output | jq -r '.cpuName'`
        uuid=`echo $output | jq -r '.uuid'`
        sysbVer=`echo $output | jq -r '.sysbVer'`
        cmd=`echo $output | jq -r '.cmd'`
        threads=`echo $output | jq -r '.threads'`

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
            echo $stamp,$memory,$newContainer,$cpuName,$uuid,$sysbVer,$cmd,$threads,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime
            echo $stamp,$memory,$newContainer,$cpuName,$uuid,$sysbVer,$cmd,$threads,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime >> sysbench-lambda.csv
        else
            echo $cpuName != $cpuTarget
            changeSubnet
            ((i--))
        fi
    done
done