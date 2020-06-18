alias cat='batcat'
alias fd='fdfind'
alias gc='git commit -m'
alias gd="git diff -- ':!package-lock.json' ':!yarn.lock'"
alias upgrade='sudo apt update && sudo apt -y upgrade'

# fzh - fuzzy search history
# See https://github.com/junegunn/fzf/wiki/examples#command-history
writecmd (){ perl -e 'ioctl STDOUT, 0x5412, $_ for split //, do{ chomp($_ = <>); $_ }' ; }

fzh() {
  ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -re 's/^\s*[0-9]+\s*//' | writecmd
}
