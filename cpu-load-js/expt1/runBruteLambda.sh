memorySetting=($(seq 128 64 3008))
childs=(2 3 4)
loop=2
wloop=2
funcName=cpu-load
memorySetting=(128 256) # testing
for child in ${childs[@]}; do
    echo 'childs,memory,newContainer,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-lambda-child$child.csv
    for memory in ${memorySetting[@]}; do
        aws lambda update-function-configuration --function-name $funcName --memory-size $memory
        for ((x=0; x<$wloop; x++)); do
            aws lambda invoke --function-name $funcName /dev/stdout
        done
        for ((i=0; i<$loop; i++)); do
            output=`aws lambda invoke --function-name $funcName --payload '{"childNum":"'$child'"}' /dev/stdout | head -n 1 | head -c -2 ; echo`
            mapfile -t array < <(jq -c '.[]' <<< $output)
            for elem in ${array[@]}; do
                newContainer=`echo $elem | jq -r '.newContainer'`
                uuid=`echo $elem | jq -r '.uuid'`
                index=`echo $elem | jq -r '.index'`
                data=`echo $elem | jq -r '.data'`
                cpu0=`echo $elem| jq -r '.cpu0'`
                cpu1=`echo $elem| jq -r '.cpu1'`
                pcpu=`echo $elem | jq -r '.totalPCPU'`
                overhead=`echo $elem | jq -r '.overhead'`

                echo $child,$memory,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead
                echo $child,$memory,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead >> out-lambda-child$child.csv
            done
        done
    done
done