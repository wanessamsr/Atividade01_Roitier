
# Docker_dhcp_dns_firewall
Repositório criado para atividade 01 - Serviços de Redes de Computadores 

# Documentação dos Arquivos Dockerfile
{   

    Usando a imagem base Ubuntu
    FROM ubuntu:latest

    // Atualizando o repositório e instalando o servidor DHCP
    RUN apt-get update && apt-get install -y isc-dhcp-server
    RUN touch /var/lib/dhcp/dhcpd.leases

    // Copiando o arquivo de configuração do DHCP para dentro do container
    COPY configs/dhcpd.conf /etc/dhcp/dhcpd.conf

    // Expondo a porta usada pelo servidor DHCP
    EXPOSE 67/udp

    // Comando para iniciar o servidor DHCP
    CMD ["dhcpd", "-f", "-d", "--no-pid"]
}

# Dockerfile.cliente
   { 
   
     FROM ubuntu:latest

    // Abrindo a porta 67 para o DHCP
    RUN apt-get update && apt-get install -y isc-dhcp-client
    RUN apt install net-tools -y

    EXPOSE 67/udp
}

# Dockerfile.dns
{ 

    Usando a imagem base Ubuntu
    FROM ubuntu:latest

    // Atualizando o repositório e instalando o servidor DNS BIND9
    RUN apt-get update && apt-get install -y bind9

    // Copiando o arquivo de configuração do DNS para dentro do container
    COPY configs/named.conf.options /etc/bind/named.conf.options

    // Expondo a porta usada pelo servidor DNS
    EXPOSE 53/tcp
    EXPOSE 53/udp

    // Comando para iniciar o servidor DNS
    CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
}

# Dockerfile.firewall
{ 
   
    FROM ubuntu:latest

    // Atualizando o repositório e instalando o firewall iptables
    RUN apt-get update && apt-get install -y iptables

    // Copiando o script de configuração do firewall para dentro do container
    COPY configs/firewall.sh /root/firewall.sh

    // Definindo o script de configuração do firewall como executável
    RUN chmod +x /root/firewall.sh

    // Comando para executar o script de configuração do firewall
    CMD ["/root/firewall.sh"]
}

# Documentação dos Arquivos de Configuração
# dhcpd.conf
{
    
    Configuração do servidor DHCP

    // Define a sub-rede e a máscara de sub-rede para alocar endereços IP aos clientes
    subnet 192.168.1.0 netmask 255.255.255.0 {

        // Define o intervalo de endereços IP disponíveis para alocação dinâmica aos clientes
        range 192.168.1.100 192.168.1.200;

        // Define o endereço IP do gateway padrão que os clientes devem usar
        option routers 192.168.1.1;

        // Especifica os servidores DNS que os clientes devem utilizar para resolver nomes de domínio
        option domain-name-servers 8.8.8.8;

        // Define o nome de domínio atribuído aos clientes
        option domain-name "example.com";

        // Especifica a interface de rede pela qual o servidor DHCP estará ouvindo
        interface eth0;
    }
}

# firewall.sh
{  
   
    #!/bin/bash
    sudo su
    // Limpando todas as regras existentes
    iptables -F
    iptables -X

    // Definindo a política padrão como DROP (bloquear tudo)
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    // Permitindo conexões de loopback
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    // Permitindo tráfego DNS
    iptables -A INPUT -p udp -s 53 -j ACCEPT
    iptables -A OUTPUT -p udp -d 53 -j ACCEPT

    // Bloqueando HTTP e HTTPS
    iptables -A INPUT -p tcp -d 80 -j DROP
    iptables -A INPUT -p tcp -d 443 -j DROP

    touch /etc/iptables/rules.v4
    iptables-save > /etc/iptables/rules.v4
    service iptables restart
    tail -f /dev/null
}

# named.conf.options
    options {
        directory "/var/cache/bind";

        // O provedor de DNS público ou outros servidores DNS
        forwarders {
            8.8.8.8;
            8.8.4.4;
        };

        // Definindo as permissões para consultas externas
        allow-query {
            any;
        };
    };

};




