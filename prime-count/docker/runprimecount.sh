cd ..; mvn clean package
cd docker
sudo docker rmi primecount
# Simulates COLD run on Docker
sudo docker build -t primecount .
#contid=`sudo docker run -m 512m --cpus=3.0 -d --rm primecount`
contid=`sudo docker run -it -d --rm primecount`
time sudo docker exec -it $contid bash -c "java -jar prime-count-1.0.0.jar 200000"
