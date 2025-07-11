# Use Rocky Linux as the base image
FROM rockylinux:9.3

# Set environment variables
ENV PYTHON_VERSION=3.12.0 \
    GO_VERSION=1.21.1 \
    TERRAFORM_VERSION=1.5.7 \
    TERRAGRUNT_VERSION=0.50.3 \
    TFLINT_VERSION=0.48.0

# Update system and install dependencies
RUN dnf update -y && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y gcc gcc-c++ make wget unzip tar git libffi-devel bzip2 bzip2-devel zlib-devel xz-devel python3.12 python3-pip golang && \
    dnf clean all

# Install Python libraries
RUN pip3.12 install --upgrade pip && \
    pip3.12 install boto3 requests ansible

# Install hcl2json
RUN /usr/local/go/bin/go install github.com/tmccombs/hcl2json@latest && \
    mv /root/go/bin/hcl2json /usr/local/bin/

# Install Terraform
#RUN ARCH=$(uname -m) && \
#    if [ "$ARCH" == "x86_64" ]; then GO_ARCH="amd64"; elif [ "$ARCH" == "aarch64" ]; then GO_ARCH="arm64"; else exit 1; fi && \
#    wget https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_$TERRAFORM_VERSION_linux_$GO_ARCH.zip && \
#    unzip terraform_$TERRAFORM_VERSION_linux_$GO_ARCH.zip && \
#    mv terraform /usr/local/bin/ && \
#    rm -f terraform_$TERRAFORM_VERSION_linux_$GO_ARCH.zip

# Install Terragrunt
#RUN ARCH=$(uname -m) && \
#    if [ "$ARCH" == "x86_64" ]; then GO_ARCH="amd64"; elif [ "$ARCH" == "aarch64" ]; then GO_ARCH="arm64"; else exit 1; fi && \
#    wget https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_VERSION/terragrunt_linux_$GO_ARCH && \
#    mv terragrunt_linux_$GO_ARCH /usr/local/bin/terragrunt && \
#    chmod +x /usr/local/bin/terragrunt

# Install TFLint
#RUN ARCH=$(uname -m) && \
#    if [ "$ARCH" == "x86_64" ]; then GO_ARCH="amd64"; elif [ "$ARCH" == "aarch64" ]; then GO_ARCH="arm64"; else exit 1; fi && \
#    wget https://github.com/terraform-linters/tflint/releases/download/v$TFLINT_VERSION/tflint_linux_$GO_ARCH.zip && \
#    unzip tflint_linux_$GO_ARCH.zip && \
#    mv tflint /usr/local/bin/ && \
#    rm -f tflint_linux_$GO_ARCH.zip

# Set PATH for Go
#ENV PATH="/usr/local/go/bin:$PATH"

# Default command
CMD ["/bin/bash"]
