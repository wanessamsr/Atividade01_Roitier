
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


# Testes Realizados
# DHCP
Configuração do Servidor DHCP:

O servidor DHCP foi configurado conforme especificado no arquivo dhcpd.conf.
Foram definidos os parâmetros de sub-rede, intervalo de endereços IP, gateway padrão, servidores DNS e nome de domínio.
Teste de Conectividade dos Clientes:

Foram configurados clientes para obter endereços IP automaticamente do servidor DHCP.
Os clientes foram capazes de se conectar à rede e receber endereços IP válidos dentro do intervalo especificado.
A configuração do gateway padrão e dos servidores DNS também foi bem-sucedida nos clientes.

# DNS
Configuração do Servidor DNS:

O servidor DNS BIND9 foi configurado conforme especificado no arquivo named.conf.options.
Foram definidos os servidores DNS forwarders e as permissões de consulta externa.
Teste de Resolução de Nomes:

Foram realizados testes de resolução de nomes de domínio usando o servidor DNS.
O servidor DNS foi capaz de resolver nomes de domínio para seus respectivos endereços IP.
Os clientes foram capazes de se comunicar com outros dispositivos na rede usando os nomes de domínio resolvidos.

# Firewall
Configuração do Firewall:

O script firewall.sh foi configurado conforme especificado para controlar o tráfego de rede.
Foram definidas regras para permitir o tráfego de loopback, tráfego DNS e bloquear o tráfego HTTP e HTTPS.

# Teste de Acesso à Rede:

Foram realizados testes de acesso à rede a partir de dispositivos internos e externos.
O firewall foi capaz de permitir o tráfego necessário para operações de rede, como acesso à Internet e resolução de nomes de domínio.
O bloqueio do tráfego HTTP e HTTPS foi verificado, impedindo o acesso a sites via navegadores da web.

# Resultados
Todos os testes foram bem-sucedidos, e os serviços de DHCP, DNS e Firewall foram configurados e funcionando conforme esperado.
A configuração dos serviços foi validada por meio de testes de conectividade e funcionalidade de rede.
Não foram encontrados problemas significativos durante o processo de configuração e testes.
A utilização de volumes Docker foi implementada para persistência de dados quando necessário, garantindo que as configurações dos serviços permaneçam mesmo após reinicializações dos contêineres.

# Passo a Passo: Testes dos Serviços de Rede
# 1. Configuração dos Serviços
# 1.1. DHCP:

Configurar o arquivo dhcpd.conf com as opções desejadas.
Exemplo: nano configs/dhcpd.conf
# 1.2. DNS:

Configurar o arquivo named.conf.options com as opções desejadas.
Exemplo: nano configs/named.conf.options

# 1.3. Firewall:

Configurar o script firewall.sh com as regras desejadas.
Exemplo: nano configs/firewall.sh

# 2. Construção e Execução dos Contêineres Docker
# 2.1. DHCP:

Construir a imagem do servidor DHCP:
    docker build -t dhcp_server -f Dockerfile .
    
Executar o contêiner DHCP:
    docker run -d --name dhcp_container dhcp_server

# 2.2. DNS:

Construir a imagem do servidor DNS:
    docker build -t dns_server -f Dockerfile.dns .

Executar o contêiner DNS:
    docker run -d --name dns_container dns_server

# 2.3. Firewall:

Construir a imagem do firewall:
    docker build -t firewall -f Dockerfile.firewall .

Executar o contêiner Firewall:
    docker run -d --name firewall_container firewall

# 3. Testes de Conectividade e Funcionalidade
# 3.1. Teste de DHCP:

Verificar o status do servidor DHCP:
    docker exec -it dhcp_container service isc-dhcp-server status

Conectar um cliente à rede e verificar se obtém um endereço IP atribuído pelo DHCP.

# 3.2. Teste de DNS:

Verificar o status do servidor DNS:
    docker exec -it dns_container service bind9 status

Realizar consultas de resolução de nomes de domínio:
    docker exec -it dns_container nslookup example.com

# 3.3. Teste de Firewall:

Verificar o status do firewall:
    docker exec -it firewall_container iptables -L


