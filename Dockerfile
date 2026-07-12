FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG RUNNER_VERSION=2.330.0
ARG DOCKER_GID=112

# ----------------------------
# Dependências
# ----------------------------
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    jq \
    git \
    unzip \
    gnupg \
    lsb-release \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    libssl-dev \
    libffi-dev \
    libglib2.0-0 \
    libcairo2 \
    libcairo-gobject2 \
    libgdk-pixbuf-2.0-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    shared-mime-info \
    fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# NodeJS
# ----------------------------

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

RUN apt-get install -y nodejs

# ----------------------------
# Docker CLI
# ----------------------------

RUN install -m 0755 -d /etc/apt/keyrings

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN chmod a+r /etc/apt/keyrings/docker.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" \
  > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin

# ----------------------------
# GitHub Runner User
# ----------------------------

RUN groupadd -g ${DOCKER_GID} docker-host

RUN useradd \
    --create-home \
    --shell /bin/bash \
    docker

RUN usermod -aG docker-host docker

# ----------------------------
# Runner
# ----------------------------

WORKDIR /home/docker

RUN mkdir actions-runner

WORKDIR /home/docker/actions-runner

RUN curl -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    -o runner.tar.gz

RUN tar xzf runner.tar.gz

RUN chown -R docker:docker /home/docker

RUN ./bin/installdependencies.sh

WORKDIR /home/docker

COPY start.sh .

RUN chmod +x start.sh

USER docker

ENTRYPOINT ["./start.sh"]
