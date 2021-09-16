# If you come from bash you might have to change your $PATH.
VERSION=$(lsb_release -rs)

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="minimal"
GRUVBOX_THEME="dark"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"


# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  colored-man-pages
  extract
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration
#faster load, may require manual load after installs
for dump in ~/.zcompdump(N.mh+24); do
    # Install plugins if there are plugins that have not been installed
    compinit
done
autoload -Uz compinit
compinit -C


setopt extendedglob
unsetopt AUTO_CD

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8


export EDITOR='nvim'
export VISUAL='nvim'
#nvim terminal specific settings
if [ -n "${NVIM_LISTEN_ADDRESS+x}" ]; then
  alias h='nvr -o'
  alias v='nvr -O'
  alias t='nvr --remote-tab'
  # alias e='nvr'
  export VISUAL='nvr -cc split --remote-wait -c "set bufhidden=delete"'
  export EDITOR="$VISUAL"
fi

bindkey -v
export KEYTIMEOUT=1
autoload -z edit-command-line
zle -N edit-command-line
# bindkey "^E" edit-command-line

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Use beam shape cursor for each new prompt.
make_beam() {
   echo -ne '\e[5 q'
}

# Do so now
make_beam

# And at the start of each prompt
autoload -U add-zsh-hook
add-zsh-hook preexec make_beam

bindkey -M viins ${terminfo[kdch1]} delete-char	# Del key
bindkey "^?" backward-delete-char

if [[ $HOME/.config/theme.yml ]]; then
    export THEME=$(cat $HOME/.config/theme.yml)
fi 

# Aliases
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias tlmgr='tllocalmgr'
alias sv='sudoedit'
alias vim='nvim'
alias lgout='i3-msg exit'
alias py='python'

local gprefix
zstyle -s ':zim:git' aliases-prefix 'gprefix' || gprefix=g

# Git
alias ${gprefix}='git'

# Branch (b)
alias ${gprefix}b='git branch'
alias ${gprefix}bc='git checkout -b'
alias ${gprefix}bl='git branch -vv'
alias ${gprefix}bL='git branch --all -vv'
alias ${gprefix}bm='git branch --move'
alias ${gprefix}bM='git branch --move --force'
alias ${gprefix}bs='git show-branch'
alias ${gprefix}bS='git show-branch --all'
alias ${gprefix}bx='git-branch-delete-interactive'
alias ${gprefix}bX='git-branch-delete-interactive --force'

# Commit (c)
alias ${gprefix}c='git commit --verbose'
alias ${gprefix}ca='git commit --all'
alias ${gprefix}cm='git commit --message'
alias ${gprefix}co='git checkout'
alias ${gprefix}cO='git checkout --patch'
alias ${gprefix}cf='git commit --amend --reuse-message HEAD'
alias ${gprefix}cF='git commit --verbose --amend'
alias ${gprefix}cp='git cherry-pick --ff'
alias ${gprefix}cP='git cherry-pick --no-commit'
alias ${gprefix}cr='git revert'
alias ${gprefix}cR='git reset "HEAD^"'
alias ${gprefix}cs='git show --pretty=format:"${_git_log_medium_format}"'
alias ${gprefix}cS='git commit -S'
alias ${gprefix}cv='git verify-commit'

# Conflict (C)
alias ${gprefix}Cl='git --no-pager diff --diff-filter=U --name-only'
alias ${gprefix}Ca='git add $(gCl)'
alias ${gprefix}Ce='git mergetool $(gCl)'
alias ${gprefix}Co='git checkout --ours --'
alias ${gprefix}CO='gCo $(gCl)'
alias ${gprefix}Ct='git checkout --theirs --'
alias ${gprefix}CT='gCt $(gCl)'

# Data (d)
alias ${gprefix}d='git ls-files'
alias ${gprefix}dc='git ls-files --cached'
alias ${gprefix}dx='git ls-files --deleted'
alias ${gprefix}dm='git ls-files --modified'
alias ${gprefix}du='git ls-files --other --exclude-standard'
alias ${gprefix}dk='git ls-files --killed'
alias ${gprefix}di='git status --porcelain --short --ignored | sed -n "s/^!! //p"'

# Fetch (f)
alias ${gprefix}f='git fetch'
alias ${gprefix}fc='git clone'
alias ${gprefix}fm='git pull'
alias ${gprefix}fr='git pull --rebase'
alias ${gprefix}fu='git fetch --all --prune && git merge --ff-only @\{u\}'

# Grep (g)
alias ${gprefix}g='git grep'
alias ${gprefix}gi='git grep --ignore-case'
alias ${gprefix}gl='git grep --files-with-matches'
alias ${gprefix}gL='git grep --files-without-match'
alias ${gprefix}gv='git grep --invert-match'
alias ${gprefix}gw='git grep --word-regexp'

# Index (i)
alias ${gprefix}ia='git add'
alias ${gprefix}iA='git add --patch'
alias ${gprefix}iu='git add --update'
alias ${gprefix}id='git diff --no-ext-diff --cached'
alias ${gprefix}iD='git diff --no-ext-diff --cached --word-diff'
alias ${gprefix}ir='git reset'
alias ${gprefix}iR='git reset --patch'
alias ${gprefix}ix='git rm --cached -r'
alias ${gprefix}iX='git rm --cached -rf'

# Log (l)
pretty_format='oneline'
alias ${gprefix}l='git log --decorate --pretty="${pretty_format}"'
alias ${gprefix}ls='git log --decorate --stat --pretty="${pretty_format}"'
alias ${gprefix}ld='git log --decorate --stat --patch --full-diff --pretty="${pretty_format}"'
alias ${gprefix}lo='git log --decorate --pretty="${pretty_format}"'
alias ${gprefix}lO='git log --decorate --pretty="${pretty_format}"'
alias ${gprefix}lg='git log --decorate --all --remotes --graph --oneline --first-parent'
alias ${gprefix}lG='git log --decorate --all --remotes --graph --pretty=short'
alias ${gprefix}lv='git log --decorate --show-signature --pretty="${pretty_format}"'
alias ${gprefix}lc='git shortlog --summary --numbered'
alias ${gprefix}lr='git reflog'

# Merge (m)
alias ${gprefix}m='git merge'
alias ${gprefix}ma='git merge --abort'
alias ${gprefix}mC='git merge --no-commit'
alias ${gprefix}mF='git merge --no-ff'
alias ${gprefix}mS='git merge -S'
alias ${gprefix}mv='git merge --verify-signatures'
alias ${gprefix}mt='git mergetool'

# Push (p)
alias ${gprefix}p='git push'
alias ${gprefix}pf='git push --force-with-lease'
alias ${gprefix}pF='git push --force'
alias ${gprefix}pa='git push --all'
alias ${gprefix}pA='git push --all && git push --tags'
alias ${gprefix}pt='git push --tags'
alias ${gprefix}pc='git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'
alias ${gprefix}pp='git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'

# Rebase (r)
alias ${gprefix}r='git rebase'
alias ${gprefix}ra='git rebase --abort'
alias ${gprefix}rc='git rebase --continue'
alias ${gprefix}ri='git rebase --interactive'
alias ${gprefix}rs='git rebase --skip'

# Remote (R)
alias ${gprefix}R='git remote'
alias ${gprefix}Rl='git remote --verbose'
alias ${gprefix}Ra='git remote add'
alias ${gprefix}Rx='git remote rm'
alias ${gprefix}Rm='git remote rename'
alias ${gprefix}Ru='git remote update'
alias ${gprefix}Rp='git remote prune'
alias ${gprefix}Rs='git remote show'

# Stash (s)
alias ${gprefix}s='git stash'
alias ${gprefix}sa='git stash apply'
alias ${gprefix}sx='git stash drop'
alias ${gprefix}sX='git-stash-clear-interactive'
alias ${gprefix}sl='git stash list'
alias ${gprefix}sd='git stash show --patch --stat'
alias ${gprefix}sp='git stash pop'
alias ${gprefix}sr='git-stash-recover'
alias ${gprefix}ss='git stash save --include-untracked'
alias ${gprefix}sS='git stash save --patch --no-keep-index'
alias ${gprefix}sw='git stash save --include-untracked --keep-index'
alias ${gprefix}su='git stash show --patch | git apply --reverse'

# Submodule (S)
alias ${gprefix}S='git submodule'
alias ${gprefix}Sa='git submodule add'
alias ${gprefix}Sf='git submodule foreach'
alias ${gprefix}Si='git submodule init'
alias ${gprefix}SI='git submodule update --init --recursive'
alias ${gprefix}Sl='git submodule status'
alias ${gprefix}Sm='git-submodule-move'
alias ${gprefix}Ss='git submodule sync'
alias ${gprefix}Su='git submodule foreach git pull origin master'
alias ${gprefix}Sx='git-submodule-remove'

# Tag (t)
alias ${gprefix}t='git tag'
alias ${gprefix}ts='git tag --sign'
alias ${gprefix}tv='git verify-tag'
alias ${gprefix}tx='git tag --delete'

# Working tree (w)
alias ${gprefix}ws='git status --short'
alias ${gprefix}d='git diff'
alias ${gprefix}wS='git status'
alias ${gprefix}wd='git diff --no-ext-diff'
alias ${gprefix}wD='git diff --no-ext-diff --word-diff'
alias ${gprefix}wr='git reset --soft'
alias ${gprefix}wR='git reset --hard'
alias ${gprefix}wc='git clean --dry-run'
alias ${gprefix}wC='git clean -d --force'
alias ${gprefix}wx='git rm -r'
alias ${gprefix}wX='git rm -rf'

alias calc='insect'
alias agi='sudo apt install'
alias agu='sudo apt upgrade'
alias agd='sudo apt update'
alias aga='sudo apt autoremove'
alias re='reboot'
alias cnr='./compile.sh && ./run.sh'

# Aliases for cargo 
alias cgo='cargo'
alias cgr='cargo run'
alias cgb='cargo build'
alias cgc='cargo check'

# App wrappers
alias -g spo='spotify &!; exit'
alias -g slk='slack &!; exit'
alias -g dsc='Discord &!; exit'

# Changing theme
alias -g lt="toggle_theme --light"
alias -g dt="toggle_theme --dark"

alias o='xdg-open'
alias e='nvr -cc split --remote -c "set bufhidden=delete"'
alias lsl='ls'
alias cna="source $HOME/.miniconda/bin/activate && conda activate"
alias cnd="conda deactivate && conda deactivate"
alias ssh='kitty +kitten ssh'
alias rm='safe-rm'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
