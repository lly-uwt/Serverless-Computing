memorySetting=($(seq 128 64 3008))
loop=5
wloop=2
childs=(2 3 4)
funcName=cpu-load

# # testing
# loop=1
# wloop=0
# childs=(2)
# memorySetting=(128 256)
# funcName=test3

for child in ${childs[@]}; do
    echo 'childs,memory,newContainer,cpuName,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-lambda-child$child-loop$loop.csv
    for memory in ${memorySetting[@]}; do
        aws lambda update-function-configuration --function-name $funcName --memory-size $memory
        for ((x=0; x<$wloop; x++)); do
            aws lambda invoke --function-name $funcName --payload '{"childNum":'$child'}' /dev/stdout
        done
        for ((i=0; i<$loop; i++)); do
            output=`aws lambda invoke --function-name $funcName --payload '{"childNum":'$child'}' /dev/stdout | head -n 1 | head -c -2 ; echo`
            mapfile -t array < <(jq -c '.[]' <<< $output)
            IFS=$'\n'
            for elem in ${array[@]}; do
                newContainer=`echo $elem | jq -r '.newContainer'`
                cpuName=`echo $elem | jq -r '.cpuName'`
                uuid=`echo $elem | jq -r '.uuid'`
                index=`echo $elem | jq -r '.index'`
                data=`echo $elem | jq -r '.data'`
                cpu0=`echo $elem| jq -r '.cpu0'`
                cpu1=`echo $elem| jq -r '.cpu1'`
                pcpu=`echo $elem | jq -r '.totalPCPU'`
                overhead=`echo $elem | jq -r '.overhead'`

                echo $child,$memory,$newContainer,$cpuName,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead
                echo $child,$memory,$newContainer,$cpuName,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead >> out-lambda-child$child-loop$loop.csv
            done
        done
    done
done