#---run this at 1st
cd ..; mvn clean package -U
cd docker
sudo docker stop memtest-container
sudo docker rmi memtest
sudo docker build -t memtest .
sudo docker run -it -d --rm --name=memtest-container memtest
#---

cpuSetting=(1 2)
memSetting=($(seq 128 128 3072))
loop=10
inputMax="100000"

echo 'time,uuid,uptime,inputmax,#prime,#cpu,memory,walltime' > out-docker.csv
for cpu in ${cpuSetting[@]}; do
    for mem in ${memSetting[@]}; do
        sudo docker update --cpus=$cpu --memory=$mem'mb' memtest-container
        for ((i=0; i<$loop; i++)); do
            whole=$(sudo docker exec -it memtest-container bash -c "java -jar prime-count-1.0.0.jar $inputMax")
            set -- $whole
            #line:offset:length
            time="$(sed -e 's/[[:space:]]*$//' <<<${1:6:30})"
            uuid="${2:5:36}"
            uptime="${7:9:10}"

            totalPrimeNum="$(sed -e 's/[[:space:]]*$//' <<<${12:14:10})"
            wallTime="$(sed -e 's/[[:space:]]*$//' <<<${13:9:10})"

            echo $time,$uuid,$uptime,$inputMax,$totalPrimeNum,$cpu,$mem,$wallTime
            echo $time,$uuid,$uptime,$inputMax,$totalPrimeNum,$cpu,$mem,$wallTime >> out-docker.csv
        done
    done
done