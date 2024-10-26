##############################################
# Functions
##############################################
function log {
  local -r level="$1"
  local -r message="$2"
  local -r timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local -r message="$1"
  log "INFO" "$message"
}

function log_warn {
  local -r message="$1"
  log "WARN" "$message"
}

function log_error {
  local -r message="$1"
  log "ERROR" "$message"
}

function is_empty {
  local -r arg="$1"

  if [[ -z "$arg" ]] || [[ "$arg" == "$EMPTY_VAL" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

function assert_not_empty {
  local -r arg_name="$1"
  local -r arg_value="$2"

  if [[ $(is_empty "$arg_value") == "true" ]]; then
    log_error "The value for '$arg_name' cannot be empty"
    print_usage
    exit 1
  fi
}

function assert_is_installed {
  local -r name="$1"

  if [[ ! "$(command -v "$name")" ]]; then
    log_error "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

function cleantf() {
    find /workspace -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
    find /workspace -type d -name ".terraform" -prune -exec rm -rf {} \;
    find /workspace -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
    find /workspace -type f -name "terragrunt_rendered.json" -prune -exec rm -rf {} \;
    find /workspace -type f -name "*.tfvars.json" -prune -exec rm -rf {} \;
}

function aws_account() {
    aws sts get-caller-identity $@ | jq -r .Account
}

function aws_assume_role_arn() {
    aws sts get-caller-identity $@ | jq -r .Arn
}

function reset-aws() {
    unset AWS_PROFILE
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_SESSION_EXPIRATION
 }

function statels {
    readonly _path=${1}
    aws s3 ls s3://github-mygainwell-acuity-tf-state/${_path}
}

function get_session_token {
    _role_arn="${1}"

    response="$(aws sts assume-role --output json --role-arn ${_role_arn} --role-session-name "$USER" --duration-seconds 3600)"

    local access_key_id
    access_key_id=$(echo "$response" | jq -r '.Credentials.AccessKeyId')
    local secret_access_key
    secret_access_key=$(echo "$response" | jq -r '.Credentials.SecretAccessKey')
    local session_token
    session_token=$(echo "$response" | jq -r '.Credentials.SessionToken')
    local expiration
    expiration=$(echo "response" | jq -r '.Credentials.Expiration')

    echo "export AWS_ACCESS_KEY_ID='$access_key_id'"
    echo "export AWS_SECRET_ACCESS_KEY='$secret_access_key'"
    echo "export AWS_SESSION_TOKEN='$session_token'"
    echo "export AWS_SESSION_EXPIRATION='$expiration'"
}

function unload_dbx {
    unset DATABRICKS_CLIENT_ID
    unset DATABRICKS_CLIENT_SECRET
    unset DATABRIKCS_ACCOUNT_ID
}

function get_aws_account_id {
    local _name="$1"

    case "$_name" in
        mgmt )  aws_account_id=350828950339 ;;
        dev  )  aws_account_id=918623739618 ;;
        stage)  aws_account_id=721214004216 ;;
        uat  )  aws_account_id=452254429706 ;;
        prod )  aws_account_id=486777228849 ;;
        ephem)  aws_account_id=515901079115 ;;
        demo )  aws_account_id=637842604963 ;;
        sbx01)  aws_account_id=798001646746 ;;
        sbx03)  aws_account_id=097211253852 ;;
        sbx04)  aws_account_id=591161269265 ;;
        sbx05)  aws_account_id=604471484504 ;;
        sbx06)  aws_account_id=313878021834 ;;
        sbx07)  aws_account_id=670104825070 ;;
        sbx09)  aws_account_id=800782569207 ;;
        sbx10)  aws_account_id=867659590468 ;;
    esac

    echo $aws_account_id
}

function get_env_name {
    local _account_id="$1"

    case "$_account_id" in
        350828950339) env_name="mgmt" ;;
        918623739618) env_name="dev" ;;
        721214004216) env_name="stage" ;;
        452254429706) env_name="uat" ;;
        486777228849) env_name="prod" ;;
        515901079115) env_name="ephem" ;;
        637842604963) env_name="sbx01" ;;
        097211253852) env_name="sbx03" ;;
        591161269265) env_name="sbx04" ;;
        604471484504) env_name="sbx05" ;;
        313878021834) env_name="sbx06" ;;
        670104825070) env_name="sbx07" ;;
        800782569207) env_name="sbx09" ;;
        867659590468) env_name="sbx10" ;;
    esac

    echo $env_name
}

function bootstrap {
    reset-aws
    export AWS_PROFILE=runner
    account_id=$(get_aws_account_id $1)
    if [ "$1" = "mgmt" ]; then
        eval "$(get_session_token --role-arn arn:aws:iam::${account_id}:role/gwt-acuity-bootstrap-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
    else
        eval "$(get_session_token --role-arn arn:aws:iam::350828950339:role/gwt-acuity-bootstrap-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
        eval "$(get_session_token --role-arn arn:aws:iam::${account_id}:role/gwt-acuity-bootstrap-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
    fi
    unset AWS_PROFILE
}

function live {
    reset-aws
    export AWS_PROFILE=runner
    account_id=$(get_aws_account_id $1)
    if [ "$1" = "mgmt" ]; then
        eval "$(get_session_token --role-arn arn:aws:iam::${account_id}:role/gwt-acuity-infra-oidc-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
    else
        eval "$(get_session_token --role-arn arn:aws:iam::350828950339:role/gwt-acuity-infra-oidc-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
        eval "$(get_session_token --role-arn arn:aws:iam::${account_id}:role/gwt-acuity-infra-execution-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
    fi
    unset AWS_PROFILE
}

function portal {
    reset-aws
    export AWS_PROFILE=runner
    account_id=$(get_aws_account_id $1)
    if [ "$1" = "mgmt" ]; then
        eval "$(get_session_token --role-arn arn:aws:iam::${account_id}:role/gwt-acuity-gw360-oidc-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
    else
        eval "$(get_session_token --role-arn arn:aws:iam::350828950339:role/gwt-acuity-gw360-oidc-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
        eval "$(get_session_token --role-arn arn:aws:iam::${account_id}:role/gwt-acuity-gw360-execution-role --role-duration-seconds 3600 --role-session-name $SESSION_NAME)"
    fi
    unset AWS_PROFILE
}

export AWS_DEFAULT_OUTPUT="json"
export AWS_CSM_ENABLED=false
export AWS_PAGER=""
export GOROOT=/opt/go
export GOPATH=/root/.go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
export SESSION_NAME="v.matukumalli@gainwelltechnologies.com"

alias pyenv='source /root/venv/bin/activate'

alias tgi='terragrunt init'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'

alias tfi='terraform init'
alias tfp='terraform plan -input=false -no-color'
alias tfa='terraform apply -input=false -no-color'
alias tfd='terraform destroy'
alias tfim='terraform import'