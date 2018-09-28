cp ../dockerfile ./
cp ../functionHandler.js ./

sudo docker stop brute-container
sudo docker rmi brute
sudo docker build -t brute .
sudo docker run -it -d --rm --name=brute-container brute

cpuSetting=($(seq .1 .01 2))
mem=128m
loop=2
# cpuSetting=(1) # testing
echo '#cpu,indexBatch,processes,totalpcpu' > out-docker.csv
for cpu in ${cpuSetting[@]}; do
    sudo docker update --cpus=$cpu --memory=$mem brute-container
    for ((i=0; i<$loop; i++)); do
        whole=$(sudo docker exec -it brute-container bash -c 'node -e "require(\"./functionHandler\").run()"')

        mapfile -t array < <(jq -c '.[]' <<< $whole)
        for elem in ${array[@]}; do
            index=`echo $elem | jq -r '.index'`
            data=`echo $elem | jq -r '.data'`
            pcpu=`echo $elem | jq -r '.totalPCPU'`

            echo $cpu,$index,$data,$pcpu
            echo $cpu,$index,$data,$pcpu >> out-docker.csv
        done
    done
done