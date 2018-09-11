
memorySetting=($(seq 128 32 3008))
wloop=10
loop=200
funcName=test
# memorySetting=(384 512)
echo 'newcontainer,time,uuid,uptime,inputmax,#prime,memory,walltime' > out-lambda.csv
for memory in ${memorySetting[@]}; do
    aws lambda update-function-configuration --function-name $funcName --memory-size $memory
    for ((x=0; x<$wloop; x++)); do
        aws lambda invoke --function-name $funcName --payload file://input.json /dev/stdout
    done
    for ((i=0; i<$loop; i++)); do
        output=`aws lambda invoke --function-name $funcName --payload file://input.json /dev/stdout | head -n 1 | head -c -2 ; echo`
        
        time=`echo $output | jq -r '.value'`
        uuid=`echo $output | jq -r '.uuid'`
        cpuUsr=`echo $output | jq -r '.cpuUsr'`
        cpuKrn=`echo $output | jq -r '.cpuKrn'`
        pid=`echo $output | jq -r '.pid'`
        cpusteal=`echo $output | jq -r '.vmcpusteal'`
        vmuptime=`echo $output | jq -r '.vmuptime'`
        newcont=`echo $output | jq -r '.newcontainer'`

        inputMax=`cat input.json | jq -r '.inputMax'`
        totalPrimeNum=`echo $output | jq -r '.totalPrimeNum'`
        wallTime=`echo $output | jq -r '.wallTime'`

        echo $newcont,$time,$uuid,$vmuptime,$inputMax,$totalPrimeNum,$memory,$wallTime
        echo $newcont,$time,$uuid,$vmuptime,$inputMax,$totalPrimeNum,$memory,$wallTime >> out-lambda.csv
    done
done