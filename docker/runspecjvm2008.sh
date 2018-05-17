# Simulates COLD run on Docker
sudo docker build -t specjvm2008 .
contid=`sudo docker run -d --rm specjvm2008`
time sudo docker exec -it $contid bash -c "cd specjvm2008 ; java Main scimark.fft.small 2 1 2 3"
