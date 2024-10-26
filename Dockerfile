FROM public.ecr.aws/ubuntu/ubuntu:24.04_stable

ARG ARCHITECTURE=amd64

ARG AWSCLI_VERSION=latest
ARG TFCLI_VERSION=latest
ARG TGCLI_VERSION=latest

ENV GOROOT=/opt/go
ENV GOPATH=/root/.go

COPY pip/requirements.txt /tmp/requirements.txt

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install apt repositories
RUN apt update -y; \
    apt upgrade -y; \
    apt --no-install-recommends install -y \
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
    apt clean; \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

#RUN mkdir -p /root/.ssh /opt/go /etc/profile.d/

#COPY etc/profile.d/profile.sh /etc/profile.d/profile.sh
#COPY root/.profile /root/.profile
#COPY root/.zshrc /root/.zshrc

#RUN python3 -m venv /root/venv
#RUN source /root/venv/bin/activate
#RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

RUN VERSION="$(curl -LsS https://releases.hashicorp.com/terraform/ | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' | sort -V | tail -1 )" ;\
    curl -LsS "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_${ARCHITECTURE}.zip" -o ./terraform.zip ;\
    unzip ./terraform.zip ;\
    rm -f ./terraform.zip ;\
    chmod +x ./terraform ;\
    mv ./terraform /usr/local/bin/terraform
RUN VERSION="$( curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .name )" ;\
    curl -LsS "https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_${ARCHITECTURE}" -o /usr/local/bin/terragrunt ;\
    chmod +x /usr/local/bin/terragrunt
RUN VERSION="$(curl -LsS https://api.github.com/repos/aquasecurity/tfsec/releases/latest | jq -r .name)"; \
    curl -LsS "https://github.com/aquasecurity/tfsec/releases/download/${VERSION}/tfsec-linux-${ARCHITECTURE}" -o /usr/local/bin/tfsec; \
    chmod +x /usr/local/bin/tfsec
RUN VERSION="$(curl -LsS https://api.github.com/repos/tmccombs/hcl2json/releases/latest | jq -r .name)"; \
    curl -LsS "https://github.com/tmccombs/hcl2json/releases/download/v${VERSION}/hcl2json_linux_${ARCHITECTURE}" -o /usr/local/bin/hcl2json; \
    chmod +x /usr/local/bin/hcl2json
RUN VERSION="$(curl -LsS https://api.github.com/repos/suzuki-shunsuke/tfcmt/releases/latest | jq -r .name)"; \
    curl -LsS "https://github.com/suzuki-shunsuke/tfcmt/releases/download/${VERSION}/tfcmt_linux_${ARCHITECTURE}.tar.gz" -o /tmp/tfcmt_linux_amd64.tar.gz;\
    tar -xvzf /tmp/tfcmt_linux_amd64.tar.gz; \
    mv tfcmt /usr/local/bin/tfcmt; \
    chmod +x /usr/local/bin/tfcmt
RUN DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.zip" )" ;\
    curl -LsS "${DOWNLOAD_URL}" -o tflint.zip ;\
    unzip tflint.zip ;\
    rm -f tflint.zip ;\
    chmod +x tflint ;\
    mv tflint /usr/local/bin/tflint
RUN DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E "https://.+?_linux_${ARCHITECTURE}.tar.gz" )" ;\
    curl -LsS "${DOWNLOAD_URL}" -o hcledit.tar.gz ;\
    tar -xf hcledit.tar.gz ;\
    rm -f hcledit.tar.gz ;\
    chmod +x hcledit ;\
    chown "$(id -u):$(id -g)" hcledit ;\
    mv hcledit /usr/local/bin/hcledit
#RUN DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/mozilla/sops/releases/latest | grep -o -E "https://.+?\.linux.${ARCHITECTURE}" )" ;\
#    curl -LsS "${DOWNLOAD_URL}" -o /usr/local/bin/sops ;\
#    chmod +x /usr/local/bin/sops
RUN curl -LsS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli.zip ;\
    mkdir -p /usr/local/awscli ;\
    unzip -q /tmp/awscli.zip -d /usr/local/awscli ;\
    /usr/local/awscli/aws/install
RUN VERSION="$(curl -LsS https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest | jq -r .name)"; \
    VERSION_NUMBER="$(echo "$VERSION" | tr -d 'v')" ;\
    curl -LsS "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/${VERSION}/aws-iam-authenticator_${VERSION_NUMBER}_linux_${ARCHITECTURE}" -o /usr/local/bin/aws-iam-authenticator ; \
    chmod +x /usr/local/bin/aws-iam-authenticator
RUN curl -LsS https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest -o /usr/local/bin/ecs-cli; \
    chmod +x /usr/local/bin/ecs-cli

WORKDIR /workspace
CMD ["/bin/zsh"]
