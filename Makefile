.PHONY: phony 
phony: help

AWS_VERSION := 2.8.5
TF_VERSION := 1.3.3
TG_VERSION := 0.39.2

GITHUB_REF ?= refs/head/null
GITHUB_SHA ?= kdjfdfksdds
VERSION_PREFIX ?= 

TF_LATEST := $(shell curl -Lss https://api.github.com/repos/hashicorp/terraform/releases/latest | jq -r .tag_name | sed 's/^V//')
TG_LATEST := $(shell curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .tag_name | sed 's/^V//')
VERSION := tf-$(TF_VERSION)-tg-$(TG_VERSION)
VERSION_LATEST := tf-$(TF_LATEST)-tg-$(TG_LATEST)
AWS_LATEST := $(shell curl -LsS https://api.github.com/repos/aws/aws-cli/tags | jq -r .[].name | head -1)

CURRENT_BRANCH := $(shell echo $(GITHUB_REF) | sed 's/refs\/heads\///')
GITHUB_SHORT_SHA := $(shell echo $(GITHUB_SHA) | cut -c1-7)
DOCKER_USER_ID := nagrcm@gmail.com
DOCKER_ORG_NAME := nagrcm
DOCKER_IMAGE := infra
DOCKER_NAME := $(DOCKER_ORG_NAME)/$(DOCKER_IMAGE)
GITHUB_USER_ID := nrmatukumalli
BUILD_DATE := $(shell date -u "+%Y-%m-%dT%H:%M:%SZ")
DOCKER_CHECK := $(shell docker buildx version 1>&2 2>/dev/null; echo $$?)

ifeq($(DOCKER_CHECK), 0)
DOCKER_COMMAND := docker buildx build --platform linux/amd64
else
DOCKER_COMMAND := docker build
endif

SHELL := bash
TXT_RED := $(shell tput setaf 1)
TXT_GREEN := $(shell tput setaf 2)
TXT_YELLOW := $(shell tput setaf 3)
TXT_RESET := $(shell tput sgr0)

define NL
endef

.PHONY: help
help:
	$(info Available Options:)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(TXT_YELLOW)%-23s $(TXT_RESET)%s\n", $$1, $$2}'

.PHONY: update-versions
update-versions:
	$(info $(NL)$(TXT_GREEN) == CURRENT VERSIONS ==$(TXT_RESET))
	@echo -e "$(TXT_GREEN)Current Terraform:$(TXT_YELLOW) $(TF_VERSION)$(TXT_RESET)"
	@if [[ $(TF_VERSION) != $(TF_LATEST) ]]; then \
	     echo -e "$(TXT_RED)Latest Terraform:$(TXT_YELLOW) $(TF_LATEST)$(TXT_RESET)" ; \
			 sed -i 's/$(TF_VERSION)/$(TF_LATEST)/g' Makefile; \
			 sed -i 's/$(TF_VERSION)/$(TF_LATEST)/g' README.md ; \
	 fi