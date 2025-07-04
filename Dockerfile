FROM --platform=$BUILDPLATFORM alpine:3.20

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
ENV GO_VERSION=1.22.3
ENV TERRAFORM_VERSION=1.8.5
ENV TERRAGRUNT_VERSION=0.56.3
ENV TFLINT_VERSION=0.50.3
ENV SOPS_VERSION=3.8.1

ENV GOROOT=/opt/go
ENV GOPATH=/root/.go

# Instal Base Packages
RUN apk add --no-cache \
    bash curl unzip zip gzip tar jq zsh openssh \
    python3 py3-pip build-base git go nodejs npm bind-tools

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-${TARGETARCH}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws

# Install Ansible
RUN pip3 install ansible boto3 requests

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip -o terraform.zip && \
    unzip terraform.zip && mv terraform /usr/local/bin/ && rm terraform.zip

# Install Terragrunt
RUN curl -fsSL https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${TARGETARCH} -o /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# Install TFLint
RUN curl -fsSL https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${TARGETARCH}.zip -o tflint.zip && \
    unzip tflint.zip && mv tflint /usr/local/bin/ && rm tflint.zip

# Install hcl2json and hcledit
RUN go install github.com/tmccombs/hcl2json@latest && \
    go install github.com/minamijoyo/hcledit@latest && \
    cp /root/go/bin/* /usr/local/bin/

# Install SOPS
RUN curl -fsSL https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${TARGETARCH} -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

RUN mkdir -p /root/.ssh /opt/go
COPY root/.zshrc /root/.zshrc
COPY root/dbxcli.sh /tmp/dbxcli.sh

RUN /tmp/dbxcli.sh

# Clean up
RUN rm -rf /var/cache/apk/* /tmp/*

WORKDIR /workspace
CMD ["/bin/zsh"]
