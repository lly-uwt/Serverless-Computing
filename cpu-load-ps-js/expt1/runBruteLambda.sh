memorySetting=($(seq 128 32 3008))
loop=5
wloop=2
funcName=cpu-load
# memorySetting=(256 512)
echo 'memory,indexBatch,processes,totalpcpu' > out-lambda.csv
for memory in ${memorySetting[@]}; do
    aws lambda update-function-configuration --function-name $funcName --memory-size $memory
    for ((x=0; x<$wloop; x++)); do
        aws lambda invoke --function-name $funcName /dev/stdout
    done
    for ((i=0; i<$loop; i++)); do
        output=`aws lambda invoke --function-name $funcName /dev/stdout | head -n 1 | head -c -2 ; echo`
        mapfile -t array < <(jq -c '.[]' <<< $output)
        for elem in ${array[@]}; do
            index=`echo $elem | jq -r '.index'`
            data=`echo $elem | jq -r '.data'`
            pcpu=`echo $elem | jq -r '.totalPCPU'`

            echo $memory,$index,$data,$pcpu
            echo $memory,$index,$data,$pcpu >> out-lambda.csv
        done
    done
done