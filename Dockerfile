FROM ubuntu:21.04

USER root

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Update system
RUN apt-get update && apt-get upgrade -y

# Install dependencies
RUN apt-get install -y apt-utils wget bash curl git gnupg nodejs openssh-client

# Install tools
RUN apt-get install -y nano net-tools iputils-ping sudo mc htop vim zsh zsh-autosuggestions zsh-syntax-highlighting ansible

ENV VERSION=3.11.1 \
    HOME="/config"

# Download and install code-server
RUN wget https://github.com/cdr/code-server/releases/download/v$VERSION/code-server_${VERSION}_amd64.deb && \
    dpkg -i code-server_${VERSION}_amd64.deb && \
    rm code-server_${VERSION}_amd64.deb

ARG INSTALL_VERSION="dotnet-sdk-3.1 dotnet-sdk-5.0"

RUN apt-get install -y wget apt-transport-https software-properties-common \
    # Register the Microsoft repository
    && wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -sr)/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    # Enable universe repositories
    && sudo add-apt-repository universe \
    # Update
    && apt-get update \
    # Install .NET SDK
    # https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu
    && apt-get install -y ${INSTALL_VERSION}

# https://github.com/Samsung/netcoredbg/releases/download/1.2.0-825/netcoredbg-linux-amd64_fixed.tar.gz
ENV NETCOREDBG_VERSION=1.2.0-825

# Download and install Samsung Debugger for .NET Core runtime
RUN wget https://github.com/Samsung/netcoredbg/releases/download/$NETCOREDBG_VERSION/netcoredbg-linux-amd64_fixed.tar.gz \
    && mkdir -p /usr/share/netcoredbg \
    && tar -oxzf netcoredbg-linux-amd64_fixed.tar.gz -C /usr/share \
    && ln -s /usr/share/netcoredbg/netcoredbg /usr/bin/netcoredbg \
    && rm netcoredbg-linux-amd64_fixed.tar.gz

# Setup python development
RUN apt-get install -y python3.9 python3-pip inetutils-ping python3-venv
RUN python3.9 -m pip install pip
RUN python3.9 -m pip install wheel
RUN python3.9 -m pip install flake8

# Setup golang development
RUN apt-get install golang -y
ENV GO111MODULE=off \
    GOPATH=$HOME/go \
    GOBIN=$HOME/go/bin

# Setup php development
RUN apt-get install -y php php-common php-cli php-curl php-gd php-intl \
    php-mbstring php-sqlite3 php-xdebug php-xml php-xmlrpc php-zip

# Setup cpp development
RUN apt-get install -y build-essential gdb

# Setup java development
RUN apt-get install -y openjdk-11-jdk

# Setup ruby development
RUN apt-get install -y ruby-full \
    && gem install ruby-debug-ide \
    && gem install debase

# Cleanup apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user, group and 
RUN useradd -s /bin/bash -m coder -d /config \
    && usermod -aG sudo coder \
    && echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER coder

# Create volumes
VOLUME [ "/config" ]

WORKDIR /config/workspace

ENTRYPOINT ["code-server", "--bind-addr", "0.0.0.0:8080"]

EXPOSE 8080 5000 5001