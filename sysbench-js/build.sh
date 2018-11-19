
sudo docker stop sysb-container
sudo docker rmi sysb

sudo docker build -t sysb .
sudo docker run -it -d --rm --name=sysb-container sysb

if [ $1 = "run" ]; then
    sudo docker exec -it sysb-container bash
fi

if [ $1 = "zip" ]; then
    sudo docker cp sysb-container:/sysb .
    zip sysb.zip sysb/* functionHandler.js

    # clean up
    sudo docker stop sysb-container
    sudo docker rmi sysb
fi