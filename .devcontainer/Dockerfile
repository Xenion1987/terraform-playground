FROM python:slim-bookworm

# Set Variables
ARG LINUX_USER=vscode
ARG TF_VERSION=1.6.6
ARG TFDOCS_VERSION=latest
ARG TFLINT_VERSION=latest
ARG TFTRIVY_VERSION=latest

# Copy setup script
COPY ./scripts/setup-docker-container.sh /tmp

# Install all applications
RUN /tmp/setup-docker-container.sh install all ${TF_VERSION} ${TFDOCS_VERSION} ${TFLINT_VERSION} ${TFTRIVY_VERSION}

# # Install OS requirements
# RUN /tmp/setup-docker-container.sh install os-requirements

# # Install pip
# RUN /tmp/setup-docker-container.sh install pip

# # Install pip requirements
# RUN /tmp/setup-docker-container.sh install pip-requirements

# # Install Terraform and Terraform tools
# RUN /tmp/setup-docker-container.sh install terraform ${TF_VERSION} \
#     && /tmp/setup-docker-container.sh install terraform-docs ${TFDOCS_VERSION} \
#     && /tmp/setup-docker-container.sh install terraform-lint ${TFLINT_VERSION} \
#     && /tmp/setup-docker-container.sh install terraform-trivy ${TFTRIVY_VERSION}

# # Install Pre-Commit
# RUN /tmp/setup-docker-container.sh install pre-commit

# # Setup python-argcomplete
# RUN /tmp/setup-docker-container.sh setup python-argcomplete

# Setup default user
RUN /tmp/setup-docker-container.sh setup user ${LINUX_USER}

# Setup default user id_rsa ssh keypair
RUN /tmp/setup-docker-container.sh setup ssh-key ${LINUX_USER}

# Set default user
USER ${LINUX_USER}
WORKDIR /home/${LINUX_USER}

# Setup oh-my-bash
RUN /tmp/setup-docker-container.sh setup oh-my-bash

# HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "pgrep bash" ]
