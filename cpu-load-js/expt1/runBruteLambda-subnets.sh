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
duration=30000
# loop = loop + wloop
loop=102
childs=(2 3 4)
funcName=cpu-load

# # testing
# duration=3000
# loop=1
# childs=(2)
# memorySetting=(128 256)
# funcName=test3

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

for child in ${childs[@]}; do
    stamp='D'$duration'C'$child'L'$loop'T'`date +%Y%m%d%H%M%S`
    echo 'childs,memory,newContainer,cpuName,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-lambda-child$child.csv
    
    for memory in ${memorySetting[@]}; do
        aws lambda update-function-configuration --function-name $funcName --memory-size $memory
        for ((x=0; x<$wloop; x++)); do
            aws lambda invoke --function-name $funcName --payload '{"childNum":'$child',"duration":'$duration'}' /dev/stdout
        done
        for ((i=0; i<$loop; i++)); do
            output=`aws lambda invoke --function-name $funcName --payload '{"childNum":'$child', "duration":'$duration'}' /dev/stdout | head -n 1 | head -c -2 ; echo`
            
            newContainer=`echo $output | jq -r '.newContainer'`
            cpuName=`echo $output | jq -r '.cpuName'`
            uuid=`echo $output | jq -r '.uuid'`
            datapoints=`echo $output | jq -r '.datapoints'`

            if [ "$cpuName" = "$cpuTarget" ]; then
                consecutiveCount=0

                mapfile -t array < <(jq -c '.[]' <<< $datapoints)
                IFS=$'\n'
                for elem in ${array[@]}; do
                    index=`echo $elem | jq -r '.index'`
                    data=`echo $elem | jq -r '.data'`
                    cpu0=`echo $elem| jq -r '.cpu0'`
                    cpu1=`echo $elem| jq -r '.cpu1'`
                    pcpu=`echo $elem | jq -r '.totalPCPU'`
                    overhead=`echo $elem | jq -r '.overhead'`

                    echo $i
                    echo $stamp,$child,$memory,$newContainer,$cpuName,$uuid,$index,$ps,$cpu0,$cpu1,$pcpu,$overhead
                    echo $stamp,$child,$memory,$newContainer,$cpuName,$uuid,$index,$ps,$cpu0,$cpu1,$pcpu,$overhead >> out-lambda-child$child.csv
                done

            else
                echo $cpuName != $cpuTarget
                changeSubnet
                ((i--))
            fi
        done
    done
done