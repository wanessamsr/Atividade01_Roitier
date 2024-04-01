docker network create --driver bridge minha_rede --subnet=192.168.1.0/24

docker build -t ubuntu-dhcp -f Dockerfile .
docker build -t ubuntu-dns -f Dockerfile.dns .
docker build -t ubuntu-firewall -f Dockerfile.firewall .
docker build -t ubuntu-cliente -f Dockerfile.cliente .

docker run -d --network minha_rede --cap-add=NET_ADMIN ubuntu-dhcp
docker run -d --network minha_rede ubuntu-dns
docker run -d --network minha_rede --privileged ubuntu-firewall
docker run -d --network minha_rede ubuntu-cliente tail -f /dev/null
