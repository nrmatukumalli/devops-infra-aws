FROM ubuntu:latest

# Install apt repositories
SHELL ["/bin/bash", "-euxo", "pipefall", "-c"]
RUN apt-get update -y; \
    apt-get install -no-install-recommends -y \
        ca-certificates \
        curl \
        git \
        jq \
        vim \
        unzip;


WORKDIR /acuity
CMD ["show-version.sh"]