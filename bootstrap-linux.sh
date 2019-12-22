#!/bin/bash

#-------------------------------------------------------------------------------------------
# Script para carga inicial de uma instalação linux, especificamente Ubuntu e derivados.
#-------------------------------------------------------------------------------------------
readonly bold=$(tput bold)
readonly red=$(tput setaf 1)
readonly green=$(tput setaf 10)
readonly reset=$(tput sgr0)
readonly yellow=$(tput setaf 11)
readonly white=$(tput setaf 15)
readonly blue=$(tput setaf 4)
readonly purple=$(tput setaf 5)
readonly orange=$(tput setaf 208)
readonly gray=$(tput setaf 250) 
readonly data=$(date '+%a %d/%b/%Y às %H:%M')

WORK_DESENVOLVIMENTO_FERRAMENTAS="/work/desenvolvimento/ferramentas"
JAVA_HOME_WORK="/work/desenvolvimento/ambiente/jdk/jdk1.8.0_231"
MAVEN_HOME_WORK="/work/desenvolvimento/ambiente/maven/apache-maven-3.6.3"
DIR_WALLPAPER="/usr/share/wallpapers/${USER}Collection"
NOME_ESTACAO=$(hostname -f)
NOME_USUARIO=$(whoami)
INSECURE_REGISTRIES_DOCKER=
USA_GTK3="S"
ehCorporativo="n"

function inicializa(){    
    cabecalho true
    tput setaf 7 && echo "Antes de começar..."    
    read -p "Esta é uma estação de trabalho corporativa? ${green}Esta opção ditará aplicação de proxy, por exemplo.${reset} [S/n] (Padrão ""n"") " ehCorporativo && tput setaf 2
    cabecalho true
    
    tput setaf 7 && echo "Qual o caminho para a pasta de ferramentas? (Padrão: ${red}${WORK_DESENVOLVIMENTO_FERRAMENTAS}${reset})" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then
        WORK_DESENVOLVIMENTO_FERRAMENTAS=$RESPOSTA
    fi
    
    cabecalho true
    tput setaf 7 && echo "Qual o caminho para home da JDK principal? (Padrão: ${red}${JAVA_HOME_WORK}${reset})" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then 
        JAVA_HOME_WORK=$RESPOSTA
    fi

    cabecalho true
    tput setaf 7 && echo "Qual o caminho para home do Maven principal? (Padrão: ${red}${MAVEN_HOME_WORK}${reset})" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then 
        MAVEN_HOME_WORK=$RESPOSTA
    fi
    
    cabecalho true
    tput setaf 7 && echo "Utiliza algum servidor de registro para imagens Docker além do Hub Central? Geralmente http://<host>:5000" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then 
        INSECURE_REGISTRIES_DOCKER=$RESPOSTA
    fi
    
    cabecalho true
    tput setaf 7 && echo 'Utilizar versão GTK 3? Caso escolha "N/n" será usado fallback GTK 2. (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
        USA_GTK3="N"
    fi
    
    cabecalho true
    tput setaf 7 && echo "$(tput smul)Revise os dados informados$(tput rmul):" && tput setaf 2
    printVariaveis
    tput setaf 7 && echo 'Confirma os dados informados? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" != "S" ] && [ "$RESPOSTA" != "s" ]; then
        finaliza
    fi
    
}

function printVariaveis(){
    echo ""
    echo "${red}Pasta ferramentas:${yellow} $WORK_DESENVOLVIMENTO_FERRAMENTAS"
    echo "${red}Java Home:${yellow} $JAVA_HOME_WORK${yellow}" $([ -z "$JAVA_HOME_WORK" ] && echo "Não preenchido." || echo "")    
    echo "${red}Maven Home:${yellow} $MAVEN_HOME_WORK${yellow}" $([ -z "$MAVEN_HOME_WORK" ] && echo "Não preenchido." || echo '')
    echo "${red}Registro Docker:${yellow} $INSECURE_REGISTRIES_DOCKER${yellow}" $([ -z "$INSECURE_REGISTRIES_DOCKER" ] && echo "Não utilizado." || echo '')
    echo "${red}Usa GTK 3:${yellow} " $([ "$USA_GTK3" = "N" ] || [ "$RESPOSTA" = "n" ] && echo "Não" || echo 'Sim')
    echo ""
}

function cabecalho(){
    clear
    echo "${yellow}===================================================================="
    echo "${yellow}  $(tput smul)BOOTSTRAP LINUX - Inicializador de Ambiente - Ubuntu e derivados$(tput rmul)  "
    echo ""
    echo "${yellow}  $(tput smul)Autor$(tput rmul)......: ${orange}Lucas Bittencourt                     "
    echo "${yellow}  $(tput smul)Execução$(tput rmul)...: ${orange}$NOME_USUARIO@$NOME_ESTACAO em ${data}${reset}${yellow} "    
    echo "${yellow}===================================================================="
    echo ""
    if [ -z "$1" ] 
        then
            echo "${bold}Dados de Inicialização:${reset}${yellow}"
            printVariaveis
    fi
    tput sgr0
}

function menu(){
    cabecalho

    tput setaf 11  
    echo "Escolha uma opção a seguir:"
    echo ''
    tput setaf 9
    echo "[CTRL-C] ou [q] para sair..."
    tput setaf 2
    echo ''
    echo "[ENTER] para execução completa!"
    tput setaf 15
    echo ''
    echo '  1. Configurar os repositórios (APT) de pacotes'
    echo '  2. Atualização da distribuição'
    echo '  3. Criação do mapeamento do Home para o diretório de trabalho (Work)'
    echo '  4. Configuração do ambiente de trabalho'
    echo '  5. Instalação de pacotes extras e restritos'
    echo '  6. Remove programas supérfulos e tunning do sistema.'    
    echo ''
    tput setaf 2
    echo -n 'Qual a opção desejada : '
    tput setaf 15
    read opcaoMenu
    
    tput sgr0
    
    if [ -z "$opcaoMenu" ]; then
        executaCompleto        
    fi    
    
    case $opcaoMenu in
        q) exit 0 ;;
        1) atualizaDistribuicao ;;
        2) instalacaoPacotesExtras ;;
        3) mapeamentoDiretorioHomeParaWork ;;
        4) configuraRepositorios ;;
        5) configuracaoAmbienteTrabalho ;;
        6) tunningSistemaEClean ;;
        *) tput setaf 9 && echo "Opção ${opcaoMenu} inválida!"&& tput sgr0 && read _ && menu ;;
    esac

}

function executaCompleto(){
    atualizaDistribuicao
    instalacaoPacotesExtras     
    mapeamentoDiretorioHomeParaWork
    configuraRepositorios
    configuracaoAmbienteTrabalho
    tunningSistemaEClean
    
    tput setaf 7 && echo 'Deseja reiniciar a máquina? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then 
        sudo reboot
    fi
}

function atualizaDistribuicao(){

    # Atualização do ambiente linux
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Atualização da distribuição"
    echo ''
    tput sgr0

    tput setaf 7 && echo 'Deseja continuar? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then

        sudo apt update -y
        sudo apt full-upgrade -y

        menuOuSair
        
    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
        menuOuSair

    else
        opcaoInvalida
    fi

}

function instalacaoPacotesExtras(){
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Instalação de pacotes extras e restritos"
    echo ''
    tput sgr0

    sudo apt install bash-completion curl libavcodec-extra libdvd-pkg kubuntu-restricted-extras kubuntu-restricted-addons ssh rar unrar p7zip-rar p7zip-full gtk2-engines-murrine gtk2-engines-pixbuf 
    gtk3-engines-unico apt-xapian-index smb4k firefox-locale-br gtk3-engines-breeze papirus-icon-theme libreoffice libreoffice-style-papirus filezilla filezilla-theme-papirus 
    libreoffice-help-pt-br libreoffice-l10n-pt-br hunspell-pt-br  hunspell-pt-pt  libreoffice-style-* libreoffice-gtk3  build-essential git kate kubuntu-driver-manager kcalc

    sudo apt install --install-recommends arc-kde adapta-kde materia-kde -y
    
    tput setaf 7 && echo 'Deseja baixar wallpapers customizados? Lembrando que irá consumir banda de internet em modo corporativo (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then       
        sudo git clone https://gist.github.com/85942af486eb79118467.git ${DIR_WALLPAPER}_1        
        sudo git clone https://github.com/LukeSmithxyz/wallpapers.git ${DIR_WALLPAPER}_2
    fi

    menuOuSair
}

function mapeamentoDiretorioHomeParaWork(){
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Criação do mapeamento do Home para o diretório de trabalho (Work)"
    echo ''
    tput sgr0
    tput setaf 7 && echo 'Deseja realizar a configuração? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then

        if [ -d /work ]; then
            
            sudo chown -R $USER:$USER /work
        
            rm -rfv  ~/Área\ de\ Trabalho \
                    ~/Documentos \
                    ~/Downloads \
                    ~/Imagens \
                    ~/Modelos \
                    ~/Música \
                    ~/Público \
                    ~/Vídeos

            mkdir -pv	/work/área\ de\ trabalho \
                        /work/documentos \
                        /work/downloads \
                        /work/imagens \
                        /work/músicas \
                        /work/público \
                        /work/vídeos \
                        /work/desenvolvimento \
                        /work/.m2
                        
            if [ ! -d ~/Área\ de\ Trabalho ]; then
                ln -s /work/área\ de\ trabalho ~/Área\ de\ Trabalho
            fi
            
            if [ ! -d ~/Documentos ]; then
                ln -s /work/documentos ~/Documentos
            fi
            
            if [ ! -d ~/Downloads ]; then
                ln -s /work/downloads/ ~/Downloads
            fi
            
            if [ ! -d ~/Imagens ]; then
                ln -s /work/imagens ~/Imagens
            fi
            
            if [ ! -d ~/Música ]; then
                ln -s /work/músicas ~/Música
            fi

            if [ ! -d ~/Público ]; then
                ln -s /work/público ~/Público
            fi

            if [ ! -d ~/Vídeos ]; then
                ln -s /work/vídeos ~/Vídeos
            fi
            
            if [ ! -d ~/Desenvolvimento ]; then
                ln -s /work/desenvolvimento ~/Desenvolvimento
            fi

            if [ ! -d ~/.m2 ]; then
                ln -s /work/.m2 ~/.m2
            fi
        else
            tput setaf 1 && echo 'Diretório /work não existe. Fim da execução do script.'
        fi

        menuOuSair

    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
        menuOuSair

    else
        opcaoInvalida
    fi
}

function configuraRepositorios(){
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Configurando os repositórios de pacotes"
    echo ''
    echo ''
    tput sgr0

    tput setaf 7 && echo 'Deseja realizar a configuração? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then    

        sudo apt install \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg-agent \
                software-properties-common -y
        
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository \
                "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                disco \
                stable"
        # $(lsb_release -cs) \
        
        sudo add-apt-repository ppa:papirus/papirus -y
        
        #sudo dpkg --add-architecture i386
        #wget -qO - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
        #sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' -y

        menuOuSair

    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
        menuOuSair

    else
        opcaoInvalida
    fi

}

function configuracaoAmbienteTrabalho(){
    # Configuração do ambiente de desenvolvimento (Utilizando a partição /work).
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Configuração do ambiente de trabalho"
    echo ''
    tput sgr0

    echo "" | sudo tee --append /etc/profile > /dev/null    
    #Configuração para utilizar gtk 2
    if [[ $USA_GTK3 = N ]] ; then
        echo "SWT_GTK3=\"0\"" | sudo tee --append /etc/profile > /dev/null
    fi

    tput setaf 7 && echo 'Deseja configurar as definições de JAVA e MAVEN na estação? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then

        instalaJDK
        install_maven 
        
    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
        
        tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _

    else
        opcaoInvalida
    fi

    instalaDocker
    configuraCorporativo
    instalaConfiguraUsoPessoal
    
    menuOuSair
}

function tunningSistemaEClean(){
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Remove programas supérfulos e tunning do sistema."
    echo '    '
    tput sgr0

    #Melhorias de performace
    echo "vm.swappiness=1" | sudo tee --append /etc/sysctl.conf > /dev/null 
    echo "vm.vfs_cache_pressure=50" | sudo tee --append /etc/sysctl.conf > /dev/null 
    echo "vm.dirty_background_bytes=16777216" | sudo tee --append /etc/sysctl.conf > /dev/null 
    echo "vm.dirty_bytes=50331648" | sudo tee --append /etc/sysctl.conf > /dev/null 
    
    sudo apt remove apport kwrite k3b -y
    sudo apt auto-remove -y
}

function configuraCorporativo(){

    if [[ $ehCorporativo = S ]] ; then
        cabecalho

        sudo touch /etc/docker/daemon.json
        echo "{\"insecure-registries\":[\"$INSECURE_REGISTRIES_DOCKER\"]}" | sudo tee --append /etc/docker/daemon.json > /dev/null
        
        tput setaf 7 && echo 'Como está no ambiente corporativo, deseja configurar o proxy? (S/N ou s/n)' && tput setaf 2
        read RESPOSTA
        tput sgr0

        if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then
            
            tput setaf 114 && echo '' && echo 'Alterando o arquivo /etc/wgetrc' && sed -i 's/#use_proxy = on/use_proxy = on/' /etc/wgetrc
            
            tput setaf 7 && echo '' && echo 'Digite o endereço do proxy.' && tput setaf 2
            read PROXY_HOST

            tput setaf 7 && echo '' && echo 'Digite a porta do proxy.' && tput setaf 2
            read PROXY_PORTA

            tput setaf 7 && echo '' && echo 'Digite o nome do usuário de autenticação no proxy.' && tput setaf 2
            read PROXY_USUARIO
            
            tput setaf 7 && echo '' && echo 'Digite a senha do usuário de autenticação no proxy.' && tput setaf 2
            read -s PROXY_SENHA

            tput setaf 7
            echo '# Proxy' >> ~/.bashrc
            echo 'export http_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            echo 'export https_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            echo 'export ftp_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            
            echo '# Proxy' | sudo tee --append /etc/wgetrc> /dev/null
            echo 'http_proxy = http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA/' | sudo tee --append /etc/wgetrc > /dev/null
            echo 'https_proxy = https://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA/' | sudo tee --append /etc/wgetrc > /dev/null

            echo '# Proxy' | sudo tee --append /etc/apt/apt.conf > /dev/null
            echo 'Acquire::http::Proxy "http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA";' | sudo tee --append /etc/apt/apt.conf > /dev/null
            echo 'Acquire::https::Proxy "https://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA";' | sudo tee --append /etc/apt/apt.conf > /dev/null
            
            echo '# Proxy' | sudo tee --append ~/.bashrc > /dev/null
            echo 'no_proxy="localhost"' | sudo tee --append ~/.bashrc > /dev/null
            
            tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _        

        elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
            sudo rm -rf /etc/apt/apt.conf
            menuOuSair

        else
            opcaoInvalida
        fi

    fi
}

function instalaJDK(){
    local caminhoJDK=$JAVA_HOME_WORK
    
    if [ ! -d "$caminhoJDK" ]; then    
        info "Caminho da JDK não foi informado, pulando passo!"
        return
    fi
        
    info "Instalando a JDK em $caminhoJDK"
   
    if grep -Fq "JAVA_HOME="  ~/.bashrc 
        then 
        info "JDK já instalado!"
        java -version | grep "java"
    else
        echo "" | sudo tee --append ~/.bashrc > /dev/null  
        echo "# Variaveis de ambiente JDK:" | sudo tee --append ~/.bashrc 
        echo "export JAVA_HOME=\"$caminhoJDK\"" | sudo tee --append ~/.bashrc
        echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee --append ~/.bashrc
        source ~/.bashrc
    fi
}

function install_maven(){

    local caminhoMaven=$MAVEN_HOME_WORK   

    if [ ! -d "$caminhoMaven" ]; then    
        info "Caminho do Maven não foi informado, pulando passo!"
        return
    fi
    
    info "Instalando Maven em $caminhoMaven"
     
    if grep -Fq "M2_HOME="  ~/.bashrc
        then
        info "Maven já instalado!"
        mvn --version | grep "Apache Maven"
    else 
        echo "# Variaveis de ambiente Maven:" | sudo tee --append ~/.bashrc      
        echo "export M2_HOME=\"$caminhoMaven\"" | sudo tee --append ~/.bashrc
        echo "export PATH=\$M2_HOME/bin:\$PATH" | sudo tee --append ~/.bashrc       
        source ~/.bashrc
    fi        
} 

function instalaDocker(){
    sudo apt-get remove docker docker-engine docker.io containerd runc docker-compose
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose -y
    
    sudo systemctl start docker
    sudo systemctl enable docker
    docker --version
    
    sudo groupadd -f docker  # cria grupo
    sudo gpasswd -a ${USER} docker # adiciona usuário ao grupo
    sudo usermod -aG docker $USER # adiciona usuário ao grupo
}

function instalaConfiguraUsoPessoal(){
    sudo apt install google-chrome-stable gnome-pie yakuake code -y

    # Configura softwares para uso pessoal.
    cp ./autostart/* ~/.config/autostart
    cp ./conf/pies.conf ~/.config/gnome-pie
    cp ./conf/yakuakerc ~/.config/yakuakerc
    cp ./conf/settings.json  ~/.config/Code/User
}

function info(){        
    echo -e "\e[36m[INFO] $1\e[0m"
}

function menuOuSair(){
    tput setaf 2
    echo '...Pressione qualquer tecla para continuar ou CTRL-c para sair.'
    tput sgr0 && read _ && menu
}

function opcaoInvalida(){
    tput setaf 1 && echo 'Você digitou uma opção inválida.'
    menuOuSair
}

function finaliza(){
    tput setaf 2
    echo 'FIM DA CONFIGURAÇÃO DO AMBIENTE. Pressione qualquer tecla para sair...'
    tput sgr0
    read
    exit 0

}

inicializa
menu
finaliza
