#---run this at 1st
cd ..; mvn clean package -U
cd expt1
sudo docker stop brute-container
sudo docker rm brute-container
sudo docker rmi brute
sudo docker build -t brute .
sudo docker run -id --rm --name=brute-container brute
#---

cpuSetting=($(seq .1 .01 2))
mem=128m
childs=(2 3 4)
loop=5
wloop=2

# childs=(2) # testing
# cpuSetting=(1 2) # testing

for child in ${childs[@]}; do
    echo 'childs,#cpu,newContainer,uuid,indexBatch,processes,cpu0,cpu1,totalpcpu,overhead' > out-docker-child$child-loop$loop.csv

    for cpu in ${cpuSetting[@]}; do
        sudo docker update --cpus=$cpu --memory=$mem brute-container

        for ((x=0; x<$wloop; x++)); do
            sudo docker exec -it brute-container bash -c 'node -e "require(\"./functionHandler\").run('$child')"'
        done

        for ((i=0; i<$loop; i++)); do
            whole=$(sudo docker exec -i brute-container bash -c "java -jar cpu-load-1.0.0.jar $child")

            # echo $whole
            whole=($whole)
            # time="${whole[0]}"
            # time=${date:6}
            newContainer="${whole[1]}"
            newContainer=${newContainer:13}
            uuid=${whole[2]}
            uuid=${uuid:5}
            # cpuusr="${whole[3]}"
            # cpuusr=${cpuusr:7}
            # cpukrn="${whole[4]}"
            # cpukrn=${cpukrn:7}
            # cutime="${whole[5]}"
            # cutime=${cutime:7}
            # cstime="${whole[6]}"
            # cstime=${cstime:7}
            # vmuptime="${whole[7]}"
            # vmuptime=${vmuptime:9}
            # vmcpusteal="${whole[8]}"
            # vmcpusteal=${vmcpusteal:11}
            # vmcpuusr="${whole[9]}"
            # vmcpuusr=${vmcpuusr:9}
            # vmcpukrn="${whole[10]}"
            # vmcpukrn=${vmcpukrn:9}
            # vmcpuidle="${whole[11]}"
            # vmcpuidle=${vmcpuidle:10}
            output="${whole[12]}"
            output=${output:7}
            # walltime="${whole[13]}"
            # walltime=${walltime:9}

            # echo $time
            # echo $newContainer
            # echo $uuid
            # echo $cpuusr
            # echo $cpukrn
            # echo $cutime
            # echo $cstime
            # echo $vmuptime
            # echo $vmcpusteal
            # echo $vmcpuusr
            # echo $vmcpukrn
            # echo $vmcpuidle
            # echo $output
            # echo $walltime

            mapfile -t array < <(jq -c '.[]' <<< $output)
            for elem in ${array[@]}; do
                index=`echo $elem | jq -r '.index'`
                data=`echo $elem | jq -r '.data'`
                cpu0=`echo $elem | jq -r '.cpu0'`
                cpu1=`echo $elem | jq -r '.cpu1'`
                pcpu=`echo $elem | jq -r '.totalPCPU'`
                overhead=`echo $elem | jq -r '.overhead'`

                echo $child,$cpu,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead
                echo $child,$cpu,$newContainer,$uuid,$index,$data,$cpu0,$cpu1,$pcpu,$overhead >> out-docker-child$child-loop$loop.csv
            done
        done
    done
done