cp ../dockerfile ./
cp ../functionHandler.js ./

sudo docker stop brute-container
sudo docker rmi brute
sudo docker build -t brute .
sudo docker run -it -d --rm --name=brute-container brute

cpuSetting=($(seq .1 .01 2))
mem=128m
loop=2
childs=(2 3 4)
# cpuSetting=(1 2) # testing

for child in ${childs[@]}; do
    echo 'childs,#cpu,newContainer,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-docker-child$child.csv

    for cpu in ${cpuSetting[@]}; do
        sudo docker update --cpus=$cpu --memory=$mem brute-container

        for ((i=0; i<$loop; i++)); do
            whole=$(sudo docker exec -it brute-container bash -c 'node -e "require(\"./functionHandler\").run('$child')"')

            mapfile -t array < <(jq -c '.[]' <<< $whole)
            for elem in ${array[@]}; do
                newContainer=`echo $elem | jq -r '.newContainer'`
                uuid=`echo $elem | jq -r '.uuid'`
                index=`echo $elem | jq -r '.index'`
                data=`echo $elem | jq -r '.data'`
                cpu0=`echo $elem | jq -r '.cpu0'`
                cpu1=`echo $elem | jq -r '.cpu1'`
                pcpu=`echo $elem | jq -r '.totalPCPU'`
                overhead=`echo $elem | jq -r '.overhead'`
                

                echo $child,$cpu,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead
                echo $child,$cpu,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead >> out-docker-child$child.csv
            done
        done
    done
done