# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin directories if they exist
if [ -d "$HOME/bin" ] ; then
    PATH="$PATH:$HOME/bin"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$PATH:$HOME/.local/bin"
fi

# Add custom screen resolutions
xrandr --newmode "3440x1440_60.00"  419.50  3440 3696 4064 4688  1440 1443 1453 1493 -hsync +vsync
xrandr --addmode Virtual1 "3440x1440_60.00"

# set AWS defaults
export AWS_DEFAULT_REGION=ap-southeast-2

# Configure fzf
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'

# Import a local override file if it exists
if [ -f "$HOME/.local_profile" ] ; then
    . "$HOME/.local_profile"
fi
