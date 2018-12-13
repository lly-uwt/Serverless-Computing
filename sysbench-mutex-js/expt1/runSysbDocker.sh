cp ../dockerfile ./
cp ../functionHandler.js ./

sudo docker stop sysbench-container
sudo docker rmi sysbench
sudo docker build --no-cache -t sysbench .
sudo docker run -it -d --rm --name=sysbench-container sysbench

# cpuSetting=($(seq .01 .01 2))
cpuSetting=(0.07 0.11 0.13 0.16 0.2 0.23 0.26 0.3 0.34 0.38 0.41 0.45 0.48 0.52 0.55 0.59 0.66 0.69 0.73 0.77 0.78 0.81 0.84 0.87 0.91 0.94 0.98 1.02 1.06 1.1 1.14 1.17 1.21 1.25 1.28 1.32 1.39 1.44 1.48 1.52 1.55 1.59 1.63 1.59 1.63 1.66)
mem=128m
loop=55
wloop=1

# testing
# cpuSetting=(.01 2)
# loop=1
# wloop=0

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