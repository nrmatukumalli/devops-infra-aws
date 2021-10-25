FROM public.ecr.aws/amazonlinux/amazonlinux:latest

ENV GOVERSION 1.17.1
ENV GOROOT /opt/go
ENV GOPATH /root/.go

ARG tf_version=1.0.7
ARG tfsec_version=v0.58.9
ARG tflint_version=v0.32.1
ARG tfdoc_version=v0.15.0

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
    blastradius 

# Install Terraform
RUN cd /usr/local/bin && wget https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip \
    && unzip terraform_${tf_version}_linux_amd64.zip  && rm terraform_${tf_version}_linux_amd64.zip

# AWS CLI Version 2
RUN cd /root && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install \
    && rm -rf /root/awscliv2.zip \
    && rm -rf /root/aws

# Command Line Interface for ECS
RUN curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest \
    && chmod +x /usr/local/bin/ecs-cli

# Install AWS_IAM_AUTHENTICATOR
RUN curl -Lo /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator

# Install Terrafrom Linter
RUN cd /root && wget https://github.com/terraform-linters/tflint/releases/download/${tflint_version}/tflint_linux_amd64.zip \
    && unzip /root/tflint_linux_amd64.zip \
    && mv /root/tflint /usr/local/bin/tflint \
    && rm /root/tflint_linux_amd64.zip

# Terraform Security Scan	
RUN curl -Lo /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/${tfsec_version}/tfsec-linux-amd64 \
    && chmod +x /usr/local/bin/tfsec

# Terraform-docs
RUN cd /root && wget https://github.com/terraform-docs/terraform-docs/releases/download/${tfdoc_version}/terraform-docs-${tfdoc_version}-linux-amd64.tar.gz \
    && tar -xvzf terraform-docs-${tfdoc_version}-linux-amd64.tar.gz  \
    && mv terraform-docs /usr/local/bin/terraform-docs \
    && chmod +x /usr/local/bin/terraform-docs \
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

RUN rm /root/LICENSE /root/README.md

WORKDIR /root

CMD ["/bin/zsh"]