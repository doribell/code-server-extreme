FROM ubuntu:21.04

USER root

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# Update system
RUN apt-get update && apt-get upgrade -y

# Install dependencies
RUN apt-get install -y apt-utils wget bash curl git gnupg nodejs openssh-client sudo locales
RUN locale-gen en_US.UTF-8

ENV VERSION=3.11.1 \
    HOME="/config"

# Download and install code-server
RUN wget https://github.com/cdr/code-server/releases/download/v$VERSION/code-server_${VERSION}_amd64.deb && \
    dpkg -i code-server_${VERSION}_amd64.deb && \
    rm code-server_${VERSION}_amd64.deb

ARG INSTALL_VERSION="dotnet-sdk-5.0"

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

EXPOSE 8080
EXPOSE 5000
EXPOSE 5001