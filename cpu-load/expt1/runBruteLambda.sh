
memorySetting=($(seq 128 64 3008))
childs=(2 3 4)
loop=5
wloop=2
funcName=cpu-load-java

# childs=(2) # testing
# memorySetting=(384 512) # testing

for child in ${childs[@]}; do
    echo 'childs,memory,newContainer,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-lambda-child$child-loop$loop.csv

    for memory in ${memorySetting[@]}; do
        aws lambda update-function-configuration --function-name $funcName --memory-size $memory
        for ((x=0; x<$wloop; x++)); do
            aws lambda invoke --function-name $funcName --payload '{"childNum":'$child'}' /dev/stdout
        done
        for ((i=0; i<$loop; i++)); do
            whole=`aws lambda invoke --function-name $funcName --payload '{"childNum":'$child'}' /dev/stdout | head -n 1 | head -c -2 ; echo`
            
            # time=`echo $whole | jq -r '.value'`
            newContainer=`echo $whole | jq -r '.newcontainer'`
            uuid=`echo $whole | jq -r '.uuid'`
            output=`echo $whole | jq -r '.output'`
            # cpuusr=`echo $whole | jq -r '.cpuUsr'`
            # cpukrn=`echo $whole | jq -r '.cpuKrn'`
            # pid=`echo $whole | jq -r '.pid'`
            # cpusteal=`echo $whole | jq -r '.vmcpusteal'`
            # vuptime=`echo $whole | jq -r '.vmuptime'`

            mapfile -t array < <(jq -c '.[]' <<< $output)
            for elem in ${array[@]}; do
                index=`echo $elem | jq -r '.index'`
                data=`echo $elem | jq -r '.data'`
                cpu0=`echo $elem | jq -r '.cpu0'`
                cpu1=`echo $elem | jq -r '.cpu1'`
                pcpu=`echo $elem | jq -r '.totalPCPU'`
                overhead=`echo $elem | jq -r '.overhead'`

                echo $child,$memory,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead
                echo $child,$memory,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead >> out-lambda-child$child-loop$loop.csv
            done
        done
    done
done