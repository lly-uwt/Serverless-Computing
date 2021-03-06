memorySetting=($(seq 128 64 3008))
duration=30000
loop=100
wloop100=5
childs=(2 3 4)
funcName=cpu-load

# # testing
# duration=3000
# loop=1
# wloop100=0
# childs=(2)
# memorySetting=(128 256)
# funcName=test3

warmup(){
    for ((x=0; x<100; x++)); do
        aws lambda invoke --function-name $funcName --payload '{"childNum":'$child',"duration":'$duration'}' /dev/stdout &
    done
}

task(){
    output=`aws lambda invoke --function-name $funcName --payload '{"childNum":'$child', "duration":'$duration'}' /dev/stdout | head -n 1 | head -c -2 ; echo`
            
    newContainer=`echo $output | jq -r '.newContainer'`
    cpuName=`echo $output | jq -r '.cpuName'`
    uuid=`echo $output | jq -r '.uuid'`
    datapoints=`echo $output | jq -r '.datapoints'`

    mapfile -t array < <(jq -c '.[]' <<< $datapoints)
    IFS=$'\n'
    for elem in ${array[@]}; do
        index=`echo $elem | jq -r '.index'`
        ps=`echo $elem | jq -r '.ps'`
        cpu0=`echo $elem| jq -r '.cpu0'`
        cpu1=`echo $elem| jq -r '.cpu1'`
        pcpu=`echo $elem | jq -r '.totalPCPU'`
        overhead=`echo $elem | jq -r '.overhead'`

        echo $1,$2,$3,$newContainer,$cpuName,$uuid,$index,$ps,$cpu0,$cpu1,$pcpu,$overhead
        echo $1,$2,$3,$newContainer,$cpuName,$uuid,$index,$ps,$cpu0,$cpu1,$pcpu,$overhead >> out-lambda-child$2.csv
    done
}

for child in ${childs[@]}; do
    stamp='D'$duration'C'$child'W'$wloop100'L'$loop'T'`date +%Y%m%d%H%M%S`
    echo 'stamp,childs,memory,newContainer,cpuName,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-lambda-child$child.csv
    
    for memory in ${memorySetting[@]}; do
        aws lambda update-function-configuration --function-name $funcName --memory-size $memory
        for ((x=0; x<$wloop100; x++)); do
            warmup
        done
        for ((i=0; i<$loop; i++)); do
            task $stamp $child $memory &
        done
    done
done