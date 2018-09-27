
[mmon](https://www.npmjs.com/package/mmon) may useful to test this


run js `node -e 'require("./functionHandler").run()'`

loads command
```sh
sha1sum /dev/zero &
killall sha1sum
```

Docker command for clean up:
```sh
sudo docker system prune
docker rm -f $(docker ps -a -q) # in sudo bash
```