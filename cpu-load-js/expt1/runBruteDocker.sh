cp ../functionHandler.js ./

sudo docker stop brute-container
sudo docker rmi brute
sudo docker build -t brute .
sudo docker run -it -d --rm --name=brute-container brute

cpuSetting=($(seq .1 .01 2))
mem=128m
loop=2
# cpuSetting=(1) # testing
echo '#cpu,indexBatch,cpuName,cpu%,totalPsPcpu' > out-docker-proc.csv
echo '#cpu,indexBatch,pid,cpuid,psr,pcpu,totalPSpcpu,cmd' > out-docker-ps.csv
for cpu in ${cpuSetting[@]}; do
    sudo docker update --cpus=$cpu --memory=$mem brute-container
    for ((i=0; i<$loop; i++)); do
        whole=$(sudo docker exec -it brute-container bash -c 'node -e "require(\"./functionHandler\").run()"')
        mapfile -t array < <(jq -c '.[]' <<< $whole)
        echo loop $loop cpu $cpu

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
                echo $cpu,$index,$cpuName,$percent,$totalPsPcpu >> out-docker-proc.csv
            done

            for y in ${psArr[@]}; do
                pid=`echo $y | jq -r '.pid'`
                pcpu=`echo $y | jq -r '.pcpu'`
                cpuid=`echo $y | jq -r '.cpuid'`
                psr=`echo $y | jq -r '.psr'`
                cmd=`echo $y | jq -r '.cmd'`
                echo $cpu,$index,$pid,$cpuid,$psr,$pcpu,$totalPsPcpu,$cmd >> out-docker-ps.csv
            done
        done
    done
done