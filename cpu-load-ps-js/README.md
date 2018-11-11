run js
```js
node -e 'require("./functionHandler").run()'
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