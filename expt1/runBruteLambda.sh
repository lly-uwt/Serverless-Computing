benchmarks=(compress)
memorySetting=(128 256 384 512 640 768 896 1024 1152 1280 1408 1536)

echo 'newcontainer,uuid,uptime,bmName,memory,ops,duration' > out-lambda.csv
for bm in ${benchmarks[@]}; do
    for memory in ${memorySetting[@]}; do
        echo $bm $memory
        aws lambda update-function-configuration --function-name test --memory-size $memory
        for ((i=0; i<5; i++)); do
            output=`aws lambda invoke --function-name test --payload file://input.json /dev/stdout | head -n 1 | head -c -2 ; echo`
            echo $output
            # set -- $whole
            
            uuid=`echo $output | jq -r '.uuid'`
            cpuusr=`echo $output | jq -r '.cpuUsr'`
            cpukrn=`echo $output | jq -r '.cpuKrn'`
            pid=`echo $output | jq -r '.pid'`
            cpusteal=`echo $output | jq -r '.vmcpusteal'`
            vuptime=`echo $output | jq -r '.vmuptime'`
            newcont=`echo $output | jq -r '.newcontainer'`

            bmname=`echo $output | jq -r '.bmname'`
            bmscore=`echo $output | jq -r '.bmscore'`
            duration=`echo $output | jq -r '.bmtotalduration'`

            echo $newcontainer,$uuid,$vuptime,$bmname,$memory,$bmscore,$duration>> out-lambda.csv
        done
    done
done