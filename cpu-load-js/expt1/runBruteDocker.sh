cp ../dockerfile ./
cp ../functionHandler.js ./

sudo docker stop brute-container
sudo docker rmi brute
sudo docker build -t brute .
sudo docker run -it -d --rm --name=brute-container brute

cpuSetting=($(seq .1 .01 2))
mem=128m
duration=30000
loop=5
wloop=2
childs=(2 3 4)

# # testing
# duration=3000
# loop=1
# wloop=0
# childs=(2) 
# cpuSetting=(1 2)

for child in ${childs[@]}; do
    stamp='D'$duration'C'$child'W'$wloop'L'$loop'T'`date +%Y%m%d%H%M%S`
    echo 'stamp,childs,#cpu,newContainer,cpuName,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-docker.csv

    for cpu in ${cpuSetting[@]}; do
        sudo docker update --cpus=$cpu --memory=$mem brute-container
        for ((x=0; x<$wloop; x++)); do
            sudo docker exec -it brute-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run('$child','$duration')"'
        done
        for ((i=0; i<$loop; i++)); do
            output=$(sudo docker exec -it brute-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run('$child','$duration')"')

            newContainer=`echo $output | jq -r '.newContainer'`
            cpuName=`echo $output | jq -r '.cpuName'`
            uuid=`echo $output | jq -r '.uuid'`
            datapoints=`echo $output | jq -r '.datapoints'`

            mapfile -t array < <(jq -c '.[]' <<< $datapoints)
            IFS=$'\n'
            for elem in ${array[@]}; do
                index=`echo $elem | jq -r '.index'`
                ps=`echo $elem | jq -r '.ps'`
                cpu0=`echo $elem | jq -r '.cpu0'`
                cpu1=`echo $elem | jq -r '.cpu1'`
                pcpu=`echo $elem | jq -r '.totalPCPU'`
                overhead=`echo $elem | jq -r '.overhead'`
                
                echo $i
                echo $stamp,$child,$cpu,$newContainer,$cpuName,$uuid,$index,$ps,$cpu0,$cpu1,$pcpu,$overhead
                echo $stamp,$child,$cpu,$newContainer,$cpuName,$uuid,$index,$ps,$cpu0,$cpu1,$pcpu,$overhead >> out-docker.csv
            done
        done
    done
done