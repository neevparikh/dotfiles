# If you come from bash you might have to change your $PATH.
# VERSION=$(lsb_release -rs)
# Path to your oh-my-zsh installation.

SYSTEM_TYPE=$(uname -s)

if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
fi
if [ -d "$HOMEBREW_PREFIX" ]; then
  export PATH=$HOMEBREW_PREFIX/bin:$PATH
fi
export PATH=$HOME/.local/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="minimal"
GRUVBOX_THEME="dark"

if [ -d "$HOME/.cargo/bin" ]; then
  source "$HOME/.cargo/env"
fi

if [ -d "/opt/cuda/bin/" ]; then
  export PATH="/opt/cuda/bin:$PATH"
fi

if [ -d "/usr/local/cuda/bin/" ]; then
  export PATH="/usr/local/cuda/bin:$PATH"
fi

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
  git
  colored-man-pages
  extract
)
if [ -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  plugins+=(fzf-tab)
fi
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  plugins+=(zsh-autosuggestions)
fi
if [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then 
  source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# User configuration
autoload -Uz compinit
compinit

if [ -f "$ZSH/oh-my-zsh.sh" ]; then 
  source $ZSH/oh-my-zsh.sh
fi


setopt extendedglob
unsetopt AUTO_CD

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='nvim'
export VISUAL='nvim'
#nvim terminal specific settings
if which command nvr &> /dev/null; then
  alias h='nvr -o'
  alias v='nvr -O'
  alias t='nvr --remote-tab'
  alias e='nvr -s -cc "lua WindowSizeAwareSplit()"'
  export VISUAL='git-editor'
  export GIT_EDITOR='git-editor'
  export EDITOR="$VISUAL"
fi

bindkey -v
export KEYTIMEOUT=1
autoload -z edit-command-line
zle -N edit-command-line

function zle-keymap-select {
  case "$KEYMAP" in
    vicmd|prompt_vicmd|*block)  # any “command‑mode” maps
      echo -ne '\e[1 q'          # block cursor
      ;;
    main|viins|prompt_viins|''|*beam)  # any “insert‑mode” maps
      echo -ne '\e[5 q'          # beam cursor
      ;;
  esac
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
add-zsh-hook precmd make_beam
bindkey -M viins ${terminfo[kdch1]} delete-char	# Del key

# === BEGIN: Natural‑language prompt → tool, with Vim‑mode support ===

# 1) Create & clone two new keymaps for prompt mode (vi‑insert & vi‑command)
bindkey -N prompt_viins viins
bindkey -N prompt_vicmd vicmd

# 2) ESC in prompt insert → switch to prompt_vicmd
prompt_to_vicmd() { zle -K prompt_vicmd }
zle -N prompt_to_vicmd
bindkey -M prompt_viins '^[' prompt_to_vicmd

# 3) i/a/o/etc in prompt command → switch back to prompt_viins
prompt_to_viins() {
  zle vi-insert         # do the normal Vi work
  zle -K prompt_viins   # and force the keymap we really want
}
zle -N prompt_to_viins
for key in i I a A o O; do        # bound in prompt_vicmd
  bindkey -M prompt_vicmd "$key" prompt_to_viins
done

# 4) Ctrl‑o – start the prompt buffer **and switch to the prompt map**
insert_tool_prompt() {
  typeset -g _INSERT_TOOL_SAVED_BUFFER=$BUFFER   # remember what was on the line
  BUFFER='|> '
  CURSOR=${#BUFFER}

  _INSERT_TOOL_PREV_KEYMAP=$KEYMAP      # remember where we were
  zle -K prompt_viins                   # go to the prompt keymap
  zle redisplay
}
zle -N insert_tool_prompt
bindkey -M viins '^o' insert_tool_prompt

bindkey -M viins '^j' autosuggest-accept


# 5) Enter – run llm, replace buffer, **go back to the saved map**
confirm_tool_prompt() {
  local arg=${BUFFER#'|> '}                      # text after "|> "
  [[ $arg == \"*\" && $arg == *\" ]] &&          # strip outer quotes if present
      arg=${arg#\"} arg=${arg%\"}

  local result
  result=$(llm -s "Return only the command to be executed as a raw string, no string delimiters wrapping it, no yapping, no markdown, no fenced code blocks, what you return will be passed to subprocess.check_output() directly. For example, if the user asks: undo last git commit You return only: git reset --soft HEAD~1" -m "gpt-4.1-nano" "$arg")

  BUFFER="${_INSERT_TOOL_SAVED_BUFFER}${result}" # prepend saved line
  CURSOR=${#BUFFER}

  zle -K "${_INSERT_TOOL_PREV_KEYMAP:-viins}"   # restore viins / vicmd
  zle redisplay
}
zle -N confirm_tool_prompt
bindkey -M prompt_viins '^M' confirm_tool_prompt
bindkey -M prompt_vicmd '^M' confirm_tool_prompt

# # === END: Natural‑language prompt → tool, with Vim‑mode support ===

if [[ -f $HOME/.config/theme.yml ]]; then
    export THEME=$(cat $HOME/.config/theme.yml)
fi 

# Aliases
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias lsl='ls'
alias sl='ls'
alias sv='sudo -e'
alias vim='nvim'
alias py='python3'

if [ "$SYSTEM_TYPE" = "Linux" ]; then
  alias lgout='swaymsg exit'
fi

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
alias ${gprefix}cP='git cherry-pick'
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
alias ${gprefix}fm='git pull' # origin $(git branch --show-current)'
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
alias ${gprefix}ta='git tag'
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

alias ${gprefix}ap='git add --patch'

if which command insect &> /dev/null; then
  alias calc='insect'
fi

# Changing theme
if [ -f "$HOME/.local/bin/toggle-theme" ]; then
  alias -g lt="toggle-theme --light"
  alias -g dt="toggle-theme --dark"
fi

if [ -d "$HOME/.config/kitty" ]; then
  alias kssh='kitty +kitten ssh'
fi

if [ "$SYSTEM_TYPE" = "Darwin" ]; then
  alias cnvim="rm $HOME/.local/state/nvim/swap/%Users%neev%*.swp"
fi

if [ -f "$HOME/.local/bin/themed-bat" ]; then
  alias bat='themed-bat'
fi

local repo_prefix
repo_prefix=cd
if [ -d "$HOME/repos/metr" ]; then
  alias ${repo_prefix}m="cd $HOME/repos/metr/"
  alias ${repo_prefix}t="cd $HOME/repos/metr/mp4-tasks/"
  alias ${repo_prefix}e="cd $HOME/repos/metr/eval-pipeline/"
  alias ${repo_prefix}v="cd $HOME/repos/metr/vivaria/"
  alias ${repo_prefix}p="cd $HOME/repos/metr/poke-tools/"
  alias ${repo_prefix}c="cd $HOME/repos/metr/cot-monitoring/"
fi
if which command timg &> /dev/null; then
  alias timg="timg -p kitty"
fi

if which command fzf &> /dev/null; then
  FD_BASE_ARGS='--follow --hidden --exclude .git --no-ignore-vcs --color=always'

  export FZF_PREVIEW_COMMAND="~/.local/share/nvim/lazy/fzf/bin/fzf-preview.sh  {}"
  export FZF_DEFAULT_COMMAND="fd $FD_BASE_ARGS"
  export FZF_DIR_COMMAND="fd --type directory $FD_BASE_ARGS"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FZF_DIR_COMMAND"

  export FZF_PREVIEW_OPTS="--preview '$FZF_PREVIEW_COMMAND' --preview-window 'right:50%:wrap:<100(down:30%)' --bind '?:toggle-preview'"
  export FZF_ALT_C_OPTS="$FZF_PREVIEW_OPTS"
  export FZF_CTRL_R_OPTS="$FZF_PREVIEW_OPTS"
  export FZF_CTRL_T_OPTS="$FZF_PREVIEW_OPTS"

  export FZF_DEFAULT_OPTS="--layout=reverse --ansi --height=~40% --color=gutter:-1 --bind tab:down,shift-tab:up $FZF_PREVIEW_OPTS "

  source <(fzf --zsh)
fi 

if [ -d "$HOME/.viv-task-dev" ]; then
  export TASK_DEV_HOME="$HOME/.viv-task-dev"
  export PATH="${PATH}:${TASK_DEV_HOME}/dev/bin" 
fi

if which command jj &> /dev/null; then
  source <(COMPLETE=zsh jj)
fi
