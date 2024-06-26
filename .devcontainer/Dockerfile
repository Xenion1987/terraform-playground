FROM python:slim-bookworm

# Set Variables
ARG LINUX_USER
ARG TERRAFORM_VERSION
ARG TERRAFORMER_VERSION
ARG TFDOCS_VERSION
ARG TFLINT_VERSION
ARG TFTRIVY_VERSION
ARG TERRAGRUNT_VERSION

# Copy setup script
COPY ./scripts/setup-docker-container.sh /tmp
COPY requirements.txt /tmp

# Install all applications
RUN chmod +x /tmp/setup-docker-container.sh && \
    /tmp/setup-docker-container.sh install all terraform ${TERRAFORM_VERSION} ${TERRAFORMER_VERSION} ${TFDOCS_VERSION} ${TFLINT_VERSION} ${TFTRIVY_VERSION} ${TERRAGRUNT_VERSION}
