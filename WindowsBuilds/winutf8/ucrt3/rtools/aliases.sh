# Some good standards, which are not used if the user
# creates his/her own .bashrc/.bash_profile

# --show-control-chars: help showing Korean or accented characters
alias ls='ls --color=auto --show-control-chars'
alias ll='ls -l'

# Recent versions of mintty set this variable to require UTF-8, but that
# causes trouble when building on systems without support for UTF-8 locale
unset LC_CTYPE
