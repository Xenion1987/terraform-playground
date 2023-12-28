ARG TERRAFORM_VERSION=1.6
ARG TFLINT_VERSION=latest
ARG TERRAGRUNT_VERSION=latest

FROM debian:12-slim
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt update \
    && apt -y purge imagemagick imagemagick-6-common \
    && apt -y install \
    dialog apt-utils sudo man-db curl wget gpg lsb-release git jq \
    && apt -y dist-upgrade \
    && apt -y autoremove \
    && apt -y autoclean \
    && apt -y clean \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform and Terraform tools
RUN curl \
    --silent \
    --output /tmp/install_terraform.sh \
    --url https://raw.githubusercontent.com/devcontainers/features/main/src/terraform/install.sh \
    && bash /tmp/install_terraform.sh ${TERRAFORM_VERSION} ${TFLINT_VERSION} ${TERRAGRUNT_VERSION} \
    && TF_DOCS_V=$(curl -s "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest" | jq -r '.tag_name') \
    && case $(uname -m) in x86_64) ARCH=amd64;;aarch64) ARCH=arm64;; *) ARCH=$(uname -m);; esac \
    && curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/${TF_DOCS_V}/terraform-docs-${TF_DOCS_V}-$(uname)-${ARCH}.tar.gz \
    && tar -xzf ./terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && mv terraform-docs /usr/local/bin/

# Install pre-commit
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt update \
    && apt -y install \
    python3-minimal python3-pip\
    && apt -y autoremove \
    && apt -y autoclean \
    && apt -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade --break-system-packages pre-commit

# Install Docker-in-Docker
## Temporary solution until https://github.com/devcontainers/features/issues/577 is fixed
# COPY ./scripts/install-docker-in-docker.sh /tmp/install-docker-in-docker.sh
# RUN bash /tmp/install-docker-in-docker.sh
