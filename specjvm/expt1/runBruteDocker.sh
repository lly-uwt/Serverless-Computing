#---run this at 1st
cd ..; mvn clean package -U
cd expt1
sudo docker stop brute-container
sudo docker rmi brute
sudo docker build -t brute .
sudo docker run -it -d --rm --name=brute-container brute
#---

# time sudo docker exec -it brute-container bash -c "cd specjvm2008 ; java Main scimark.fft.small 2 1 2 3" > ex-out.txt
# cat ex-out.txt
# whole=`cat ex-out.txt`

benchmarks=(compress)
cpuSetting=($(seq .1 .01 2))
mem=128m
loop=200
bt=1
params="2 $bt 1 10" #benchmarkThreads, warmuptime, iterations, iterationTime
# cpuSetting=(1) # testing
echo 'time,uuid,uptime,bmName,#bt,#cpu,ops,duration' > out-docker.csv
for bm in ${benchmarks[@]}; do
    for cpu in ${cpuSetting[@]}; do
        echo $bm $cpu
        sudo docker update --cpus=$cpu --memory=$mem brute-container
        for ((i=0; i<$loop; i++)); do
            whole=$(sudo docker exec -it brute-container bash -c "cd specjvm2008 ; java Main $bm $params")
            set -- $whole
            #line:offset:length
            time="$(sed -e 's/[[:space:]]*$//' <<<${1:6:30})"
            uuid="${2:5:36}"
            uptime="${7:9:10}"

            bmName="$(sed -e 's/[[:space:]]*$//' <<<${12:7:20})"
            ops="$(sed -e 's/[[:space:]]*$//' <<<${13:8:10})"
            duration="$(sed -e 's/[[:space:]]*$//' <<<${15:16:10})"

            echo $time,$uuid,$uptime,$bmName,$bt,$cpu,$ops,$duration
            echo $time,$uuid,$uptime,$bmName,$bt,$cpu,$ops,$duration >> out-docker.csv
        done
    done
done