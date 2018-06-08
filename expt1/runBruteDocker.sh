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

# cpuSetting=(.2 .4 .6 .8 1 1.2 1.4 1.6 1.8 2.0)
cpuSetting=(1) # testing
echo 'uuid,uptime,bmName,#cpu,ops,duration' > out-docker.csv
for bm in ${benchmarks[@]}; do
    for cpu in ${cpuSetting[@]}; do
        echo $bm $cpu
        sudo docker update --cpus=$cpu brute-container
        for ((i=0; i<5; i++)); do
            whole=$(sudo docker exec -it brute-container bash -c "cd specjvm2008 ; java Main $bm 2 5 1 10")
            set -- $whole

            echo "${2:5:36}"
            echo "${7:9:10}"
            echo "${12:7:20}"
            echo $cpu
            echo "${13:8:10}"
            echo "${15:16:10}"

            echo "${2:5:36}","${7:9:10}","$(sed -e 's/[[:space:]]*$//' <<<${12:7:20})",$cpu,"$(sed -e 's/[[:space:]]*$//' <<<${13:8:10})","$(sed -e 's/[[:space:]]*$//' <<<${15:16:10})" >> out-docker.csv
        done
    done
done