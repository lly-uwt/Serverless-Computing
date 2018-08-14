time_start=`date`

#---run these at 1st
cd ..; mvn clean package -U
cd TLP
sudo docker stop tlp-container
sudo docker rmi tlp
sudo docker build -t tlp .
sudo docker run -it -d --rm --name=tlp-container tlp
#---

# time sudo docker exec -it tlp-container bash -c "cd specjvm2008 ; java Main scimark.fft.small 2 1 2 3" > ex-out.txt
# cat ex-out.txt
# whole=`cat ex-out.txt`

benchmarks=(
 compress\
 scimark.fft.small\
 scimark.lu.small\
 scimark.sor.large\
 scimark.sor.small\
 scimark.sparse.small\
 scimark.monte_carlo\

 mpegaudio\
 scimark.sparse.large\
 scimark.lu.large\
 scimark.fft.large\
 serial\
 sunflow\
)

# not working in lambda
#  derby\
#  xml.transform\
#  xml.validation\
# cpuSetting=(.1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2)
cpuSetting=(1 2)
mem=128m
loop=5
params='2 5 1 10' #benchmarkThreads, warmuptime, iterations, iterationTime
echo 'uuid,uptime,bmName,#cpu,ops,duration' > all.csv
for bm in ${benchmarks[@]}; do
    for cpu in ${cpuSetting[@]}; do
        echo $bm $cpu
        sudo docker update --cpus=$cpu --memory=$mem tlp-container
        for ((i=0; i<$loop; i++)); do
            whole=$(sudo docker exec -it tlp-container bash -c "cd specjvm2008 ; java Main $bm $params")
            set -- $whole

            # echo "${2:5:36}"
            # echo "${7:9:10}"
            # echo "${12:7:20}"
            # echo $cpu
            # echo "${13:8:10}"
            # echo "${15:16:10}"

            echo "${2:5:36}","${7:9:10}","$(sed -e 's/[[:space:]]*$//' <<<${12:7:20})",$cpu,"$(sed -e 's/[[:space:]]*$//' <<<${13:8:10})","$(sed -e 's/[[:space:]]*$//' <<<${15:16:10})" >> all.csv
        done
    done
done

python3 process.py $loop

time_end=$(date)

echo "$time_start,$time_end,${benchmarks[*]},$loop,${cpuSetting[*]},$params" >> timing.txt
echo "End"