FROM ubuntu:latest

ARG TARGETPLATFORM=linux/amd64
ARG ARCHITECTURE=amd64
ARG AWS_VERSION=latest
ARG TF_VERSION=latest
ARG TG_VERSION=latest
ARG AWS_VERSION=latest
ARG TFSEC_VERSION=latest

COPY requirements.txt /tmp/pip_requirements.txt

RUN apt-get update -y; \
    apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    git \
    jq \
    vim \
    unzip \
    bc \
    docker.io \
    graphviz \
    hub \
    make \
    ncurses-base \
    openssh-client \
    openssl \
    python3 \
    python3-pip \
    zip; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir -r /tmp/pip_requirements.txt

RUN VERSION="$( curl -LsS https://releases.hashicorp.com/terraform/ | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' | sort -V | tail -1 )" ;\
    curl -LsS https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_${ARCHITECTURE}.zip -o ./terraform.zip ;\
    unzip ./terraform.zip ;\
    rm -f ./terraform.zip ;\
    chmod +x ./terraform ;\
    mv ./terraform /usr/bin/terraform

RUN VERSION="$(curl -LsS https://api.github.com/repos/aquasecurity/tfsec/releases/latest | jq -r .name)" ;\
    curl -LsS https://github.com/aquasecurity/tfsec/releases/download/${VERSION}/tfsec-checkgen-linux-amd64 -o /usr/bin/tfsec ;\
    chmod +x /usr/bin/tfsec

RUN VERSION="$(curl -LsS https://api.github.com/repos/tmccombs/hcl2json/releases/latest | jq -r .name)" ;\
    curl -LsS https://github.com/tmccombs/hcl2json/releases/download/${VERSION}/hcl2json_linux_amd64 -o /usr/bin/hcl2json ;\
    chmod +x /usr/bin/hcl2json

RUN VERSION="$( curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .name )" ;\
    curl -LsS https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_${ARCHITECTURE} -o /usr/bin/terragrunt ;\
    chmod +x /usr/bin/terragrunt

RUN DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.zip" )" ;\
    curl -LsS "${DOWNLOAD_URL}" -o tflint.zip ;\
    unzip tflint.zip ;\
    rm -f tflint.zip ;\
    chmod +x tflint ;\
    mv tflint /usr/bin/tflint

RUN DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.tar.gz" )" ;\
    curl -LsS "${DOWNLOAD_URL}" -o hcledit.tar.gz ;\
    tar -xf hcledit.tar.gz ;\
    rm -f hcledit.tar.gz ;\
    chmod +x hcledit ;\
    chown "$(id -u):$(id -g)" hcledit ;\
    mv hcledit /usr/bin/hcledit

RUN DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/mozilla/sops/releases/latest | grep -o -E "https://.+?\.linux.${ARCHITECTURE}" )" ;\
    curl -LsS "${DOWNLOAD_URL}" -o /usr/bin/sops ;\
    chmod +x /usr/bin/sops

RUN curl -LsS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli.zip ;\
    mkdir -p /usr/local/awscli ;\
    unzip -q /tmp/awscli.zip -d /usr/local/awscli ;\
    /usr/local/awscli/aws/install

COPY aws-auth /usr/bin/aws-auth

WORKDIR /data
CMD ["versions.sh"]