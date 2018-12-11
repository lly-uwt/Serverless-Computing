cp ../dockerfile ./
cp ../functionHandler.js ./

sudo docker stop sysbench-container
sudo docker rmi sysbench
sudo docker build --no-cache -t sysbench .
sudo docker run -it -d --rm --name=sysbench-container sysbench

cpuSetting=($(seq .01 .01 2))
mem=128m
loop=55
wloop=1

# testing
cpuSetting=(.01 2)
loop=1
wloop=0

stamp='W'$wloop'L'$loop'T'`date +%Y%m%d%H%M%S`
echo 'stamp,cpu,newContainer,cpuName,uuid,sysbVer,cmd,threads,totalTime,totalEvent,lateMin,lateAvg,lateMax,late95th,lateSum,fevent,fexecTime' > sysbench-docker.csv
for cpu in ${cpuSetting[@]}; do
    sudo docker update --cpus=$cpu --memory=$mem --memory-swap=$mem sysbench-container
    for ((x=0; x<$wloop; x++)); do
        sudo docker exec -it sysbench-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run()"'
    done
    for ((i=0; i<$loop; i++)); do
        output=$(sudo docker exec -it sysbench-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run()"')
        echo $output
        newContainer=`echo $output | jq -r '.newContainer'`
        cpuName=`echo $output | jq -r '.cpuName'`
        uuid=`echo $output | jq -r '.uuid'`
        sysbVer=`echo $output | jq -r '.sysbVer'`
        cmd=`echo $output | jq -r '.cmd'`
        threads=`echo $output | jq -r '.threads'`

        tt=`echo $output| jq -r '.general.totalTime'`
        te=`echo $output | jq -r '.general.totalEvent'`
        lateMin=`echo $output | jq -r '.latency.min'`
        lateAvg=`echo $output | jq -r '.latency.avg'`
        lateMax=`echo $output | jq -r '.latency.max'`
        late95th=`echo $output | jq -r '.latency."95th"'`
        lateSum=`echo $output | jq -r '.latency.sum'`
        fevent=`echo $output | jq -r '.fairness.events'`
        fexecTime=`echo $output | jq -r '.fairness.execTime'`
        
        echo $stamp,$cpu,$newContainer,$cpuName,$uuid,$sysbVer,$cmd,$threads,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime
        echo $stamp,$cpu,$newContainer,$cpuName,$uuid,$sysbVer,$cmd,$threads,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime >> sysbench-docker.csv
    done
done