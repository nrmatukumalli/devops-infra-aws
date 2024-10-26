FROM public.ecr.aws/ubuntu/ubuntu:24.04_stable

ARG TARGETPLATFORM=linux/amd64

ARG AWSCLI_VERSION=latest
ARG TFCLI_VERSION=latest
ARG TGCLI_VERSION=latest

ENV GOROOT=/opt/go
ENV GOPATH=/root/.go

COPY pip/requirements.txt /tmp/pip_requirements.txt

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install apt repositories
RUN apt-get update -y; \
    apt-get upgrade -y; \
    apt-get --no-install-recommends install -y \
    ca-certificates \
    wget \
    curl \
    git \
    jq \
    vim \
    unzip \
    python3 \
    python3-pip \
    zip \
    golang-go \
    zsh \
    dnsutils \
    tar \
    zsh \
    python3.12-venv \
    gzip; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN wget --progress=dot:giga https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

RUN mkdir -p /root/.ssh /opt/go /etc/profile.d/

COPY etc/profile.d/profile.sh /etc/profile.d/profile.sh
COPY root/.profile /root/.profile
COPY root/.zshrc /root/.zshrc

#RUN python3 -m venv /root/venv
#RUN source /root/venv/bin/activate
#RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
    VERSION="$( curl -LsS https://releases.hashicorp.com/terraform/ | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' | sort -V | tail -1 )" ; \
    for i in {1..5}; do curl -LsS \
        https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_${ARCHITECTURE}.zip -o ./terraform.zip \
        && break || sleep 15; \
    done ; \
    unzip ./terraform.zip ; \
    rm -f ./terraform.zip ; \
    chmod +x ./terraform ; \
    mv ./terraform /usr/bin/terraform

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ; \
    VERSION="$( curl -LsS https://api.github.com/repos/opentofu/opentofu/releases/latest | jq -r .tag_name | sed 's/^v//' )" ; \
    for i in {1..5}; do curl -LsS \
        https://github.com/opentofu/opentofu/releases/download/v${VERSION}/tofu_${VERSION}_${ARCHITECTURE}.deb -o ./tofu.deb \
        && break || sleep 15; \
    done ; \
    dpkg -i ./tofu.deb ;\
    rm -f ./tofu.deb ;

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
    VERSION="$( curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .name )" ; \
    for i in {1..5}; do curl -LsS \
        https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_${ARCHITECTURE} -o /usr/bin/terragrunt \
        && break || sleep 15; \
    done ;\
    chmod +x /usr/bin/terragrunt

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
    DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.zip" )" ;\
    for i in {1..5}; do curl -LsS "${DOWNLOAD_URL}" -o ./tflint.zip && break || sleep 15; done ;\
    unzip ./tflint.zip ;\
    rm -f ./tflint.zip ;\
    chmod +x ./tflint ;\
    mv ./tflint /usr/bin/tflint

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
    DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.tar.gz" )" ;\
    for i in {1..5}; do curl -LsS "${DOWNLOAD_URL}" -o ./hcledit.tar.gz && break || sleep 15; done ;\
    tar -xf ./hcledit.tar.gz ;\
    rm -f ./hcledit.tar.gz ;\
    chmod +x ./hcledit ;\
    chown "$(id -u):$(id -g)" ./hcledit ;\
    mv ./hcledit /usr/bin/hcledit 

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=amd64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=arm64; else ARCHITECTURE=amd64; fi ;\
    DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/getsops/sops/releases/latest | grep -o -E "https://.+?\.linux.${ARCHITECTURE}" | head -1 )" ;\
    for i in {1..5}; do curl -LsS "${DOWNLOAD_URL}" -o /usr/bin/sops && break || sleep 15; done ;\
    chmod +x /usr/bin/sops

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then ARCHITECTURE=x86_64; elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi ;\
    for i in {1..5}; do curl -LsS "https://awscli.amazonaws.com/awscli-exe-linux-${ARCHITECTURE}.zip" -o /tmp/awscli.zip && break || sleep 15; done ;\
    mkdir -p /usr/local/awscli ;\
    unzip -q /tmp/awscli.zip -d /usr/local/awscli ;\
    /usr/local/awscli/aws/install

WORKDIR /workspace
CMD ["/bin/zsh"]
