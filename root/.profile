##############################################
# Functions
##############################################
# Execute "script" command just once
smart_script(){
    # if there's no SCRIPT_LOG_FILE exported yet
    if [ -z "$SCRIPT_LOG_FILE" ]; then
        # make folder paths
        logdirparent=~/.logs
        logdirraw=raw/$(date +%F)
        logdir=$logdirparent/$logdirraw
        logfile=$logdir/$(date +%F_%T).$$.rawlog

        # if no folder exist - make one
        if [ ! -d $logdir ]; then
            mkdir -p $logdir
        fi

        export SCRIPT_LOG_FILE=$logfile
        export SCRIPT_LOG_PARENT_FOLDER=$logdirparent

        # quiet output if no args are passed
        if [ ! -z "$1" ]; then
            script -f $logfile
        else
            script -f -q $logfile
        fi

        exit
    fi
}

# Manually saves current log file: $ savelog logname
savelog(){
    # make folder path
    manualdir=$SCRIPT_LOG_PARENT_FOLDER/manual
    # if no folder exists - make one
    if [ ! -d $manualdir ]; then
        mkdir -p $manualdir
    fi
    # make log name
    logname=${SCRIPT_LOG_FILE##*/}
    logname=${logname%.*}
    # add user logname if passed as argument
    if [ ! -z $1 ]; then
        logname=$logname'_'$1
    fi
    # make filepaths
    txtfile=$manualdir/$logname'.txt'
    rawfile=$manualdir/$logname'.rawlog'
    # make .rawlog readable and save it to .txt file
    cat $SCRIPT_LOG_FILE | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b > $txtfile
    # copy corresponding .rawfile
    cp $SCRIPT_LOG_FILE $rawfile
    printf 'Saved logs:\n    '$txtfile'\n    '$rawfile'\n'
}

function cleantf() {
  location="${HOME}/"

  sudo find ${location} -type f -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;
  sudo find ${location} -type d -name ".terraform" -prune -exec rm -rf {} \;
  sudo find ${location} -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
  sudo find ${location} -type f -name "terragrunt_rendered.json" -prune -exec rm -rf {} \;
}

function tfsum() {
  # Slurp to combine each separate json object into a single array, raw output for plain strings
  #
  # First map filters out the planned changes and builds a smaller object from the addr and action
  # Group by the actions, to put them in create, delete, read, and update arrays
  # Second map defines the action as a variable, removes the action from the object, deletes the action
  #   from each object, pulls the addr string out of the objects, and builds a string for each action group.
  #
  # Finally, run the output through another array pull to turn the array of strings into just strings.

  terraform plan -json |
    jq --slurp --raw-output '
      map(
        select(.type == "planned_change") |
          {
            addr: .change.resource.addr,
            action: .change.action
          }
      ) |
      group_by(.action) |
      map(
        .[0].action as $action |
        del (.[].action) |
        map(.addr) |
        "\($action) (\(. | length)):\n    \(map(.) | join("\n    "))\n"
      ) |
      .[]
    '
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

aws_auth() {
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

export AWS_DEFAULT_REGION=us-east-1
export AWS_PAGER=""
export GOROOT=/opt/go
export GOPATH=/root/.go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

alias tgi='terragrunt run-all init'
alias tgp='terragrunt run-all plan'
alias tga='terragrunt run-all apply'