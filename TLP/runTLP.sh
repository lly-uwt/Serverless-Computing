cd ..; mvn clean package
sudo docker build -t tlp .
sudo docker run -it -d --rm --name=tlp-container tlp
