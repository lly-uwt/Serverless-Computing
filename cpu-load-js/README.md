`npm install systeminformation`

[mmon](https://www.npmjs.com/package/mmon) may useful to test this


Docker command for clean up:
```sh
sudo docker system prune
docker rm -f $(docker ps -a -q) # in sudo bash
```