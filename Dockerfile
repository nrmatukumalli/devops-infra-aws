<<<<<<< HEAD
FROM ubuntu:latest

ARG TF_VERSION=1.0.11
ARG TFSEC_VERSION=0.63.1
ARG TFLINT_VERSION=0.33.2
ARG TFDOC_VERSION=0.16.0
ARG TG_VERSION=0.35.14

RUN apt update \
  && apt upgrade -y

RUN apt install -y curl \
  wget \
  unzip \
  zip \
  gzip \
  nodejs \
  jq \
  tar \
  dnsutils \
  python3.8 \
  vim
  
RUN apt install -y python3-pip git golang-go zsh
  
RUN pip3 install setuptools wheel
RUN	pip3 install cryptography \
=======
FROM public.ecr.aws/amazonlinux/amazonlinux:latest

ENV GOVERSION 1.17.1
ENV GOROOT /opt/go
ENV GOPATH /root/.go

ARG tf_version=1.2.4
ARG tfsec_version=v1.26.3
ARG tflint_version=v0.38.1
ARG tfdoc_version=v0.16.0

RUN yum update -y
RUN yum install -y wget \
    net-tools \
    unzip \
    gzip \
    bash-completion \
    figlet \
    zsh \
    tree \
    nodejs \
    jq \
    graphviz \
    bind-utils \
    tar

RUN amazon-linux-extras install epel
RUN amazon-linux-extras install vim
RUN amazon-linux-extras install python3.8
RUN amazon-linux-extras install ansible2
RUN amazon-linux-extras install ecs
RUN amazon-linux-extras install golang1.11

RUN pip3.8 install --upgrade pip

RUN pip3 install setuptools wheel setuptools-rust
RUN pip3 install cryptography \
>>>>>>> f693e86447d959e1cc18c784e820fe07be82c873
    PyYAML \
    boto3 \
    yq \
    bs4 \
    requests \
    databricks-cli \
    pre-commit \
    certifi \
    awscli \
    diagrams \
    pytest \
    tftest \
    s3cmd \
    checkov \
    airiam \
<<<<<<< HEAD
    blastradius \
	terraform-compliance

RUN cd /usr/local/bin && wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
    && unzip terraform_${TF_VERSION}_linux_amd64.zip  && rm terraform_${TF_VERSION}_linux_amd64.zip
	
RUN wget -O /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TG_VERSION}/terragrunt_linux_amd64 \
	&& chmod +x /usr/local/bin/terragrunt
=======
    blastradius 

# Install Terraform
RUN cd /usr/local/bin && wget https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip \
    && unzip terraform_${tf_version}_linux_amd64.zip  && rm terraform_${tf_version}_linux_amd64.zip
>>>>>>> f693e86447d959e1cc18c784e820fe07be82c873

RUN cd /root && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install \
    && rm -rf /root/awscliv2.zip \
    && rm -rf /root/aws

RUN curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest \
    && chmod +x /usr/local/bin/ecs-cli

RUN curl -Lo /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator
	
RUN cd /root && wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip	 \
    && unzip /root/tflint_linux_amd64.zip \
    && mv /root/tflint /usr/local/bin/tflint \
    && rm /root/tflint_linux_amd64.zip

RUN curl -Lo /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 \
    && chmod +x /usr/local/bin/tfsec

RUN cd /root && wget -O /root/terraform-docs-${TFDOC_VERSION}-linux-amd64.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v${TFDOC_VERSION}/terraform-docs-v${TFDOC_VERSION}-linux-amd64.tar.gz \
    && tar -xvzf /root/terraform-docs-${TFDOC_VERSION}-linux-amd64.tar.gz  \
    && mv /root/terraform-docs /usr/local/bin/terraform-docs \
    && chmod +x /usr/local/bin/terraform-docs \
<<<<<<< HEAD
    && rm /root/terraform-docs-${TFDOC_VERSION}-linux-amd64.tar.gz

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions
	
RUN mkdir -p /root/.ssh
RUN mkdir -p /opt/go

WORKDIR /root/workspace
=======
    && rm /root/terraform-docs-${tfdoc_version}-linux-amd64.tar.gz

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install
#   - eksctl
#   - kubectl

RUN mkdir -p /etc/profile.d/
COPY etc/profile.d/profile.sh /etc/profile.d/profile.sh
COPY usr/local/bin/gwokta /usr/local/bin/gwokta
COPY usr/local/bin/gwsso /usr/local/bin/gwsso
COPY usr/local/bin/aws-auth /usr/local/bin/aws-auth

RUN chmod +x /usr/local/bin/gwokta
RUN chmod +x /usr/local/bin/gwsso
RUN chmod +x /usr/local/bin/aws-auth

RUN rm /root/LICENSE /root/README.md

WORKDIR /root

>>>>>>> f693e86447d959e1cc18c784e820fe07be82c873
CMD ["/bin/zsh"]