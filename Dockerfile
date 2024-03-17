# Usando a imagem base Ubuntu
FROM ubuntu:latest

# Atualizando o repositório e instalando o servidor DHCP
RUN apt-get update && apt-get install -y isc-dhcp-server
RUN touch /var/lib/dhcp/dhcpd.leases

# Copiando o arquivo de configuração do DHCP para dentro do container
COPY configs/dhcpd.conf /etc/dhcp/dhcpd.conf

# Expondo a porta usada pelo servidor DHCP
EXPOSE 67/udp

# Comando para iniciar o servidor DHCP

CMD ["dhcpd", "-f", "-d", "--no-pid"]

