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

aws_auth() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_SESSION_EXPIRATION

    eval $(op signin my)
    op_item_id="i7vsocxltjcekrt6euscn7uply"
    aws_items=$(op get item "$op_item_id" --fields AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_TOTP_SERIAL_NUMBER)
    aws_role=$(op get item "$op_item_id" --fields Role)

    export AWS_ACCESS_KEY_ID=$(echo $aws_items | jq -r '.AWS_ACCESS_KEY_ID')
    export AWS_SECRET_ACCESS_KEY=$(echo $aws_items | jq -r '.AWS_SECRET_ACCESS_KEY')
    AWS_TOTP_SERIAL_NUMBER=$(echo $aws_items | jq -r '.AWS_TOTP_SERIAL_NUMBER')

    aws-auth --serial-number $AWS_TOTP_SERIAL_NUMBER --role-arn $aws_role --role-duration-seconds 3600 --token-code $(op get totp "$op_item_id")
}

git_oauth () {
    unset GITHUB_OAUTH_TOKEN 

    eval $(op signin my)
    op_item_id=$(op list items | jq -r '.[] | select(.overview.title == "github:fullpriv:pat") | .uuid')
    export GITHUB_OAUTH_TOKEN=$(op get item ${op_item_id} --fields password)
}

#export GITHUB_OAUTH_TOKEN=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
export GITHUB_OAUTH_TOKEN=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
export AUTHENTICATION_URL=fedssoawiew1.clmgmt.entsvcs.com
export DXC_FEDSSO_USERNAME=vmatukumall2@dxcmgmt.com
export AWS_DEFAULT_REGION=us-east-1
export AWS_PAGER=""
export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin:/home/vmatukumalli/.local/bin:/mnt/c/Program Files/Docker/Docker/resources/bin:/mnt/c/ProgramData/DockerDesktop/version-bin"

export GOROOT=/usr/local/go
export GOPATH=$HOME/.local/go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

#export TF_DATA_DIR=/home/vmatukumalli/.terraform

# Start logging into new file
alias startnewlog='unset SCRIPT_LOG_FILE && smart_script -v'
alias opon='eval $(op signin my)'
alias tfi='terraform init -upgrade=true'
alias tfp='terraform plan'
alias tfa='terraform apply -auto-approve'
alias tfd='terraform destroy -auto-approve'
alias tfv='terraform validate'
alias tfc='find . -type d -name ".terraform.lock.hcl" -prune -exec rm -rf {} \;'
alias creds='eval $(aws_auth)'

alias connect='aws ssm start-session --target'
alias gwrepo='cd /home/vmatukumalli/Github/mygainwell/repos'
alias myrepo='cd /home/vmatukumalli/Github/nrmatukumalli'


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
