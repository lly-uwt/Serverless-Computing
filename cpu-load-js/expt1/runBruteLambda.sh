memorySetting=($(seq 128 32 3008))
loop=5
wloop=2
funcName=cpu-load
# memorySetting=(128 512)
echo '#memory,indexBatch,cpuName,cpu%,totalPsPcpu' > out-lambda-proc.csv
echo '#menory,indexBatch,pid,cpuid,psr,pcpu,totalPSpcpu,cmd' > out-lambda-ps.csv
for memory in ${memorySetting[@]}; do
    aws lambda update-function-configuration --function-name $funcName --memory-size $memory
    for ((x=0; x<$wloop; x++)); do
        aws lambda invoke --function-name $funcName /dev/stdout
    done
    for ((i=0; i<$loop; i++)); do
        output=`aws lambda invoke --function-name $funcName /dev/stdout | head -n 1 | head -c -2 ; echo`
        mapfile -t array < <(jq -c '.[]' <<< $output)
        echo loop $loop memory $memory

        for elem in ${array[@]}; do
            index=`echo $elem | jq -r '.index'`
            cpudata=`echo $elem | jq -r '.cpudata'`
            psdata=`echo $elem | jq -r '.psdata'`
            psArray=`echo $psdata | jq -r '.ps'`
            totalPsPcpu=`echo $psdata | jq -r '.totalcpu'`
            mapfile -t cpuArr < <(jq -c '.[]' <<< $cpudata)
            mapfile -t psArr < <(jq -c '.[]' <<< $psArray)

            for x in ${cpuArr[@]}; do
                cpuName=`echo $x | jq -r '.name'`
                percent=`echo $x | jq -r '."%"'`
                echo $memory,$index,$cpuName,$percent,$totalPsPcpu >> out-lambda-proc.csv
            done

            for y in ${psArr[@]}; do
                pid=`echo $y | jq -r '.pid'`
                pcpu=`echo $y | jq -r '.pcpu'`
                cpuid=`echo $y | jq -r '.cpuid'`
                psr=`echo $y | jq -r '.psr'`
                cmd=`echo $y | jq -r '.cmd'`
                echo $memory,$index,$pid,$cpuid,$psr,$pcpu,$totalPsPcpu,$cmd >> out-lambda-ps.csv
            done
        done
    done
done