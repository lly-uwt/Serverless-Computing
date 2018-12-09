cp ../dockerfile ./
cp ../functionHandler.js ./

sudo docker stop sysbench-container
sudo docker rmi sysbench
sudo docker build --no-cache -t sysbench .
sudo docker run -it -d --rm --name=sysbench-container sysbench

cpuSetting=($(seq .1 .01 2))
maxPrime=5000
events=1
mem=128m
loop=5
wloop=2

# testing
# cpuSetting=(1 2)
# maxPrime=200
# events=1
# loop=1
# wloop=0

stamp='P'$maxPrime'E'$events'W'$wloop'L'$loop'T'`date +%Y%m%d%H%M%S`
echo 'stamp,#cpu,newContainer,cpuName,uuid,threads,maxPrime,speed,totalTime,totalEvent,lateMin,lateAvg,lateMax,late95th,lateSum,fevent,fexecTime' > sysbench-docker.csv
for cpu in ${cpuSetting[@]}; do
    sudo docker update --cpus=$cpu --memory=$mem --memory-swap=$mem sysbench-container
    for ((x=0; x<$wloop; x++)); do
        sudo docker exec -it sysbench-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run('$maxPrime','$events')"'
    done
    for ((i=0; i<$loop; i++)); do
        output=$(sudo docker exec -it sysbench-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run('$maxPrime','$events')"')
        echo $output
        newContainer=`echo $output | jq -r '.newContainer'`
        cpuName=`echo $output | jq -r '.cpuName'`
        uuid=`echo $output | jq -r '.uuid'`
        threads=`echo $output | jq -r '.threads'`
        maxPrime=`echo $output | jq -r '.maxPrime'`
        speed=`echo $output| jq -r '.speed'`
        tt=`echo $output| jq -r '.general.totalTime'`
        te=`echo $output | jq -r '.general.totalEvent'`
        lateMin=`echo $output | jq -r '.latency.min'`
        lateAvg=`echo $output | jq -r '.latency.avg'`
        lateMax=`echo $output | jq -r '.latency.max'`
        late95th=`echo $output | jq -r '.latency."95th"'`
        lateSum=`echo $output | jq -r '.latency.sum'`
        fevent=`echo $output | jq -r '.fairness.events'`
        fexecTime=`echo $output | jq -r '.fairness.execTime'`
        
        echo $stamp,$cpu,$newContainer,$cpuName,$uuid,$threads,$maxPrime,$speed,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime
        echo $stamp,$cpu,$newContainer,$cpuName,$uuid,$threads,$maxPrime,$speed,$tt,$te,$lateMin,$lateAvg,$lateMax,$late95th,$lateSum,$fevent,$fexecTime >> sysbench-docker.csv
    done
done