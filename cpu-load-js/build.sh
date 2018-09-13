sudo docker build -t cpuload .
sudo docker run -it -d --rm --name=cpuload-container cpuload