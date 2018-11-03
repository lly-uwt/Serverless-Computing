sudo docker stop sysbench-container
sudo docker rmi sysbench
sudo docker build -t sysbench .
sudo docker run -it -d --rm --name=sysbench-container sysbench
# sudo docker exec -it sysbench-container bash
sudo docker cp sysbench-container:/sysb .
zip done.zip sysb/* functionHandler.js