# Use Rocky Linux as the base image
FROM rockylinux:9.3

ARG TARGETARCH

# Set environment variables
ENV PYTHON_VERSION=3.12.0 \
    GO_VERSION=1.21.1 \
    TERRAFORM_VERSION=1.12.2 \
    TERRAGRUNT_VERSION=0.83.1 \
    TFLINT_VERSION=0.58.0

# Update system and install dependencies
RUN dnf update -y && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y \
        gcc gcc-c++ make wget unzip tar git \
        libffi-devel bzip2 bzip2-devel zlib-devel \
        xz-devel python3.12 python3-pip golang jq \
        zsh bind-utils && \
    dnf clean all

# Install Python libraries
RUN python3.12 -m venv /root/venv
RUN /root/venv/bin/pip3 install --upgrade pip && \
    /root/venv/bin/pip3 install boto3 requests ansible

# Install hcl2json
RUN go install github.com/tmccombs/hcl2json@latest && \
    mv /root/go/bin/hcl2json /usr/local/bin/

# Install Terraform
RUN if [ "$TARGETARCH" == "linux/amd64" ]; then GO_ARCH="amd64"; elif [ "$TARGETARCH" == "linux/arm64" ]; then GO_ARCH="arm64"; else exit 1; fi && \
    echo $TERRAFOM_VERSION && \
    echo $GO_ARCH && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${GO_ARCH}.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_${GO_ARCH}.zip && \
    mv terraform /usr/local/bin/ && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_${GO_ARCH}.zip

# Install Terragrunt
RUN if [ "$TARGETARCH" == "linux/amd64" ]; then GO_ARCH="amd64"; elif [ "$TARGETARCH" == "linux/arm64" ]; then GO_ARCH="arm64"; else exit 1; fi && \
    wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_$GO_ARCH && \
    mv terragrunt_linux_$GO_ARCH /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# Install TFLint
RUN if [ "$TARGETARCH" == "linux/amd64" ]; then GO_ARCH="amd64"; elif [ "$TARGETARCH" == "linux/arm64" ]; then GO_ARCH="arm64"; else exit 1; fi && \
    wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_$GO_ARCH.zip && \
    unzip tflint_linux_$GO_ARCH.zip && \
    mv tflint /usr/local/bin/ && \
    rm -f tflint_linux_$GO_ARCH.zip

# Install SOPS
RUN if [ "${TARGETARCH}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETARCH}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
    DOWNLOAD_URL=$( curl -LsS https://api.github.com/repos/getsops/sops/releases/latest | grep -o -E "https://.+?\.linux.${ARCHITECTURE}" | head -1 ) ;\
    for i in {1..5}; do curl -LsS "${DOWNLOAD_URL}" -o /usr/bin/sops && break || sleep 15; done ;\
    chmod +x /usr/bin/sops

# Install AWS CLI
RUN if [ "${TARGETARCH}" = "linux/amd64" ]; then ARCHITECTURE=x86_64; elif [ "${TARGETARCH}" = "linux/arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi ;\
    for i in {1..5}; do curl -LsS "https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE}.zip" -o /tmp/awscli.zip && break || sleep 15; done ;\
    mkdir -p /usr/local/awscli ;\
    unzip -q /tmp/awscli.zip -d /usr/local/awscli ;\
    /usr/local/awscli/aws/install

RUN wget --progress=dot:giga https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

RUN mkdir -p /root/.ssh/ /root/.local/bin /root/profile.d
COPY root/.zshrc /root/.zshrc
COPY root/dbxcli.sh /tmp/dbxcli.sh
RUN /tmp/dbxcli.sh

WORKDIR /workspace
CMD ["/bin/zsh"]
