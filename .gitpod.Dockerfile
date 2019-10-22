FROM gitpod/workspace-dotnet

RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update 
    
    
RUN wget http://mirrors.edge.kernel.org/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3_amd64.deb \
    && wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.3_amd64.deb \
    && dpkg -i libicu60_60.2-3ubuntu3_amd64.deb libssl1.0.0_1.0.2n-1ubuntu5.3_amd64.deb    
    
RUN echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/18.04/prod bionic main" >> /etc/apt/sources.list.d/microsoft-prod.list
RUN  apt-get update \
     && apt install -y powershell

#RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/v6.2.3/powershell_6.2.3-1.ubuntu.18.04_amd64.deb \
#    && dpkg -i powershell_6.2.3-1.ubuntu.18.04_amd64.deb \
#    && apt-get install -f


# Install custom tools, runtime, etc. using apt-get
# For example, the command below would install "bastet" - a command line tetris clone:
#
# RUN apt-get update \
#    && apt-get install -y bastet \
#    && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#
# More information: https://www.gitpod.io/docs/42_config_docker/
