sudo docker stop cpuload-container
sudo docker rm cpuload-container
sudo docker rmi cpuload
sudo docker build -t cpuload .
sudo docker run -it -d --rm --name=cpuload-container cpuload
sudo docker exec -it cpuload-container bash