#---run this at 1st
cd ..; mvn clean package -U
cd docker
sudo docker stop memtest-container
sudo docker rmi memtest
sudo docker build -t memtest .
sudo docker run -it -d --rm --name=memtest-container memtest
#---

benchmarks=(compress)
cpuSetting=(1 2)
memSetting=($(seq 128 128 3072))
loop=10
bt=1
params="2 $bt 1 10" #benchmarkThreads, warmuptime, iterations, iterationTime

echo 'time,uuid,uptime,bmName,#bt,#cpu,memory,ops,duration' > out-docker.csv
for bm in ${benchmarks[@]}; do
    for cpu in ${cpuSetting[@]}; do
        for mem in ${memSetting[@]}; do
            sudo docker update --cpus=$cpu --memory=$mem'mb' memtest-container
            for ((i=0; i<$loop; i++)); do
                whole=$(sudo docker exec -it memtest-container bash -c "cd specjvm2008 ; java Main $bm $params")
                set -- $whole
                #line:offset:length
                time="$(sed -e 's/[[:space:]]*$//' <<<${1:6:30})"
                uuid="${2:5:36}"
                uptime="${7:9:10}"

                bmName="$(sed -e 's/[[:space:]]*$//' <<<${12:7:20})"
                ops="$(sed -e 's/[[:space:]]*$//' <<<${13:8:10})"
                duration="$(sed -e 's/[[:space:]]*$//' <<<${15:16:10})"

                echo $time,$uuid,$uptime,$bmName,$bt,$cpu,$mem,$ops,$duration
                echo $time,$uuid,$uptime,$bmName,$bt,$cpu,$mem,$ops,$duration >> out-docker.csv
            done
        done
    done
done