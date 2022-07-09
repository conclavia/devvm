alias ans='ansible-playbook -K'
alias cat='batcat'
alias fd='fdfind'
alias gc='git commit -m'
alias gd="git diff -- :!package-lock.json :!yarn.lock"
alias gds="git diff --staged -- :!package-lock.json :!yarn.lock"
alias gr='git pull --rebase && git rebase origin/master'
alias upgrade='sudo apt update && sudo apt -y upgrade && sudo snap refresh'

# Wait for user confirmation
confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# AWS
alias cfn-ls="aws cloudformation list-stacks --query 'StackSummaries[?StackStatus!=\`DELETE_COMPLETE\`].[StackName]' --output text | sort"
alias cfn-out="aws cloudformation describe-stacks --query 'Stacks[0].Outputs[*].[Description,OutputValue]' --output table --stack-name"
alias sqs-len="aws sqs get-queue-attributes --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible ApproximateNumberOfMessagesDelayed --queue-url"
alias sqs-purge="aws sqs purge-queue --queue-url"

cfn-rm() {
  STACK_NAME="$1"
  if [[ "${STACK_NAME}" == "" ]]; then
    echo "ERROR: Must provide the name of the stack to delete!"
    return 1
  fi
  echo "Deleting ${STACK_NAME}..."
  aws cloudformation list-stack-resources --stack-name "${STACK_NAME}" --query "StackResourceSummaries[?ResourceType=='AWS::S3::Bucket'].PhysicalResourceId" | jq .[] | xargs -L1 -I'{}' aws s3 rm --recursive s3://{}
  aws cloudformation delete-stack --stack-name "${STACK_NAME}"
  echo "  done!"
}

cfn-clean() {
  GREP_STRING=${1:-${USER}}
  FORCE_FLAG=$2

  if [[ "${GREP_STRING}" == "" ]]; then
    echo "ERROR: Please provide a search string or ensure that the \$USER variable is set!"
    return 1
  fi

  echo "Searching for stacks containing ${GREP_STRING}..."
  STACKS_TO_DELETE=`cfn-ls | grep ${GREP_STRING}`

  if [[ "${STACKS_TO_DELETE}" == "" ]]; then
    echo "  No stacks found to clean up!"
    return 0
  fi

  echo
  echo "The following stacks will be deleted:"
  echo
  echo "${STACKS_TO_DELETE}" | pr -T -o 4
  echo
  if [[ "${FORCE_FLAG}" != "-f" ]]; then
    confirm || return 0
  fi
  echo

  export -f cfn-rm
  echo "${STACKS_TO_DELETE}" | xargs -L1 -I'{}' bash -c 'cfn-rm {}'

  echo
  echo "Waiting for stacks to finish deleting..."
  echo "${STACKS_TO_DELETE}" | xargs -L1 -I'{}' aws cloudformation wait stack-delete-complete --stack-name {}
  echo "  done!"
}

cfn-me() {
  cfn-ls | grep ${USER}
}

# fzh - fuzzy search history
# See https://github.com/junegunn/fzf/wiki/examples#command-history
writecmd (){ perl -e 'ioctl STDOUT, 0x5412, $_ for split //, do{ chomp($_ = <>); $_ }' ; }

fzh() {
  ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -re 's/^\s*[0-9]+\s*//' | writecmd
}

# Import a local override file if it exists
if [ -f "$HOME/.local_bash_aliases" ] ; then
    . "$HOME/.local_bash_aliases"
fi
