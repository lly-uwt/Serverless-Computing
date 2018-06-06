#---run this at 1st
cd ..; mvn clean package
cd TLP
sudo docker stop tlp-container
sudo docker rmi tlp
sudo docker build -t tlp .
sudo docker run -it -d --rm --name=tlp-container tlp
#---

# time sudo docker exec -it tlp-container bash -c "cd specjvm2008 ; java Main scimark.fft.small 2 1 2 3" > ex-out.txt
# cat ex-out.txt
# whole=`cat ex-out.txt`

benchmarks=(derby
 compress\
 mp3gaudio\
 scimark.fft.large\
 scimark.fft.small\
 scimark.lu.large\
 scimark.lu.small\
 scimark.sor.large\
 scimark.sor.small\
 scimark.sparse.large\
 scimark.sparse.small\
 scimark.monte_carlo\
 serial\
 sunflow\ 
 xml.tranform\
 xml.validation\
)
# sunflow and xml transform need fix
cpuSetting=(1 2)

for bm in ${benchmarks[@]}; do
    echo 'uuid,uptime,bmName,#cpu,ops,duration' > $bm.csv
    for cpu in ${cpuSetting[@]}; do
        echo $bm $cpu
        sudo docker update --cpus=$cpu tlp-container
        for ((i=0; i<5; i++)); do
            whole=$(sudo docker exec -it tlp-container bash -c "cd specjvm2008 ; java Main $bm 2 5 1 10")
            set -- $whole

            echo "${2:5:36}"
            echo "${7:9:10}"
            echo "${12:7:20}"
            echo $cpu
            echo "${13:8:10}"
            echo "${15:16:10}"

            echo "${2:5:36}","${7:9:10}","$(sed -e 's/[[:space:]]*$//' <<<${12:7:20})",$cpu\
            "$(sed -e 's/[[:space:]]*$//' <<<${13:8:10})","$(sed -e 's/[[:space:]]*$//' <<<${15:16:10})" >> $bm.csv
        done
    done
done