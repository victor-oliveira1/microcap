# Microcap
Captive portal escrito em bash puro + CGI (backend) e Bootstrap (FrontEnd)

### Descrição
Microcap nasceu com o intuito de ser super simples e leve, capaz de ser executado em um roteador básico com OpenWRT (4MB flash + 32MB RAM).
Com ele, é possível "alugar" internet, possibilitando um gerenciamento fácil da rede, bloqueando ou desbloqueando os equipamentos que nela se conectam

### Como funciona?
O intuito principal, é "alugar" internet, uma rede wifi aberta, que ao se conectar, uma página com produtos de seu empreendimento seja apresentada, e no fim dela, estejam os valores para se utilizar a internet (a propaganda é a alma do negócio né amigos? :P)

### Como instalar?
Como ainda está em desenvolvimento, isso será detalhado em um momento futuro. O foco agora é terminar o básico pra poder pensar nisso depois (estou trabalhando 
nisso em meu tempo livre)
* Para a configuração, é necessário instalar o pacote **uhttpd** no roteador OpenWRT.
* Após isso, basta enviar os diretórios **www** e **opt** para o caminho **/**
* Configurar uma nova interface com o nome ap no arquivo **/etc/config/network**
    > config interface 'ap'  
    > option proto 'static'  
    > option ipaddr '10.50.0.254'  
    > option netmask '255.255.255.0'  
* Configurar uma rede wifi com o nome AP no arquivo **/etc/config/wireless**
    > config wifi-iface  'AP'
    > option device 'radio0'  
    > option network 'ap'  
    > option mode 'ap'  
    > option ssid 'GUEST'  
    > option encryption 'none'  
* Copiar o arquivo **firewall.user** para **/etc**
* Adicionar as linhas abaixo à seção **config uhttpd main** do arquivo **/etc/config/uhttpd**
    > option index_page       cgi-bin/captive  
    > option error_page       /cgi-bin/captive  
* Adicionar a linha abaixo no crontab
    > */1 * * * * /opt/microcap/bin/cleaner.sh

### Motivação
Sou analista de infraestrutura, e queria muito aprender a programar para a web. Devido a uma idéia que surgiu de uma pessoa muito querida, acabei estudando para colocar esse projeto em prática. Estou muito satisfeito com o resultado, aprendi bastante e vou seguir adicionando algumas funções sempre que puder.

### Capturas de tela

**Tela principal**
![Página principal](https://raw.githubusercontent.com/victor-oliveira1/microcap/main/captura_3.jpeg)

**Alteração de SSID**
![Página principal](https://raw.githubusercontent.com/victor-oliveira1/microcap/main/captura_2.jpeg)

**Desbloqueio de dispositivo**
![Página principal](https://raw.githubusercontent.com/victor-oliveira1/microcap/main/captura_1.jpeg)

2021 Victor Oliveira <victor.oliveira@gmx.com>
