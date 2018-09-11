#---run this at 1st
cd ..; mvn clean package -U
cd expt1
sudo docker stop brute-container
sudo docker rmi brute
sudo docker build -t brute .
sudo docker run -it -d --rm --name=brute-container brute
#---

cpuSetting=($(seq .1 .01 2))
mem=128m
loop=200
inputMax="100000"
# cpuSetting=(1) # testing
echo 'time,uuid,uptime,inputmax,#prime,#cpu,walltime' > out-docker.csv
for cpu in ${cpuSetting[@]}; do
    sudo docker update --cpus=$cpu --memory=$mem brute-container
    for ((i=0; i<$loop; i++)); do
        whole=$(sudo docker exec -it brute-container bash -c "java -jar prime-count-1.0.0.jar $inputMax")
        set -- $whole
        #line:offset:length
        time="$(sed -e 's/[[:space:]]*$//' <<<${1:6:30})"
        uuid="${2:5:36}"
        uptime="${7:9:10}"

        totalPrimeNum="$(sed -e 's/[[:space:]]*$//' <<<${12:14:22})"
        wallTime="$(sed -e 's/[[:space:]]*$//' <<<${13:9:15})"

        echo $time,$uuid,$uptime,$inputMax,$totalPrimeNum,$cpu,$wallTime
        echo $time,$uuid,$uptime,$inputMax,$totalPrimeNum,$cpu,$wallTime >> out-docker.csv

    done
done