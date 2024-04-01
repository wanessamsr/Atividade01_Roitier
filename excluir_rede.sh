sudo docker rm -f $(sudo docker ps -a -q)

sudo docker network rm minha_rede

sudo docker rmi ubuntu-dhcp
sudo docker rmi ubuntu-dns
sudo docker rmi ubuntu-firewall
sudo docker rmi ubuntu-cliente
