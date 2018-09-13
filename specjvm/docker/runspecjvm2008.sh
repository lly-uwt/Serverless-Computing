cd ..; mvn clean package
cd docker
sudo docker rmi specjvm2008
# Simulates COLD run on Docker
sudo docker build -t specjvm2008 .
#contid=`sudo docker run -m 512m --cpus=3.0 -d --rm specjvm2008`
contid=`sudo docker run -it -d --rm specjvm2008`
time sudo docker exec -it $contid bash -c "cd specjvm2008 ; java Main scimark.fft.small 2 1 2 3"
