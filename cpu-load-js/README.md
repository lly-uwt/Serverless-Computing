run js
```sh
node -e 'require("./functionHandler").run(2, true)'
# or
source ~/.nvm/nvm.sh ; node -e 'require("./functionHandler").run(2, true)'
```

loads command
```sh
sha1sum /dev/zero &
killall sha1sum
```

Docker command for clean up:
```sh
sudo docker system prune
sudo docker rm -f $(sudo docker ps -a -q)
```

Links: https://hub.docker.com/_/amazonlinux/