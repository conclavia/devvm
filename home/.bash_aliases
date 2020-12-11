alias ans='ansible-playbook -K'
alias cat='batcat'
alias fd='fdfind'
alias gc='git commit -m'
alias gd="git diff -- :!package-lock.json :!yarn.lock"
alias gds="git diff --staged -- :!package-lock.json :!yarn.lock"
alias gr='git pull --rebase && git rebase origin/master'
alias upgrade='sudo apt update && sudo apt -y upgrade'

# AWS
alias cfn-ls="aws cloudformation list-stacks --query 'StackSummaries[?StackStatus!=\`DELETE_COMPLETE\`].[StackName]' --output text | sort"
alias cfn-out="aws cloudformation describe-stacks --query 'Stacks[0].Outputs[*].[Description,OutputValue]' --output table --stack-name"
alias sqs-len="aws sqs get-queue-attributes --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible ApproximateNumberOfMessagesDelayed --queue-url"
alias sqs-purge="aws sqs purge-queue --queue-url"

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
