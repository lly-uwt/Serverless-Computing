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
    TAIL='D'$duration'C'$child'W'$wloop'L'$loop'T'`date +%Y%m%d%H%M%S`
    echo 'childs,#cpu,newContainer,cpuName,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-docker-$TAIL.csv

    for cpu in ${cpuSetting[@]}; do
        sudo docker update --cpus=$cpu --memory=$mem brute-container
        for ((x=0; x<$wloop; x++)); do
            sudo docker exec -it brute-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run('$child','$duration')"'
        done
        for ((i=0; i<$loop; i++)); do
            whole=$(sudo docker exec -it brute-container bash -c 'source ~/.nvm/nvm.sh ; node -e "require(\"./functionHandler\").run('$child','$duration')"')
            mapfile -t array < <(jq -c '.[]' <<< $whole)
            IFS=$'\n'
            for elem in ${array[@]}; do
                # echo $elem
                newContainer=`echo $elem | jq -r '.newContainer'`
                cpuName=`echo $elem | jq -r '.cpuName'`
                uuid=`echo $elem | jq -r '.uuid'`
                index=`echo $elem | jq -r '.index'`
                data=`echo $elem | jq -r '.data'`
                cpu0=`echo $elem | jq -r '.cpu0'`
                cpu1=`echo $elem | jq -r '.cpu1'`
                pcpu=`echo $elem | jq -r '.totalPCPU'`
                overhead=`echo $elem | jq -r '.overhead'`
                
                echo $child,$cpu,$newContainer,$cpuName,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead
                echo $child,$cpu,$newContainer,$cpuName,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead >> out-docker-$TAIL.csv
            done
        done
    done
done