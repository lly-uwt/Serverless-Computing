Some Docker commands:
```sh
sudo docker pull <published-image>
sudo docker images
sudo docker build -t <pick-image-name> .
sudo docker run -d -rm --name=<pick-name> <image-name>
sudo docker run -it -d -rm --name=<pick-name> <image-name>
sudo docker ps
sudo docker update --cpus="1" <name/id>

# delete everything
sudo docker system prune # only dangling
sudo docker system prune -a

sudo docker rm -f $(sudo docker ps -a -q) # delete all containers
sudo docker rmi $(sudo docker images -q) # delete all images

# Kill all running containers
sudo docker ps -a | grep Up | cut -d ' ' -f 1| xargs sudo docker kill

# Remove exited containers
sudo docker ps -a | grep Exit | cut -d ' ' -f 1| xargs sudo docker rm

```