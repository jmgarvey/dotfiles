# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(zsh-autosuggestions zsh-syntax-highlighting fzf-tab git)

source $ZSH/oh-my-zsh.sh

if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

if [ -f ~/.env.env ]; then
    set -a && source ~/.env.env && set +a
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias ls="eza --color=always --icons=always"
alias df="duf"
alias cd="z"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias lazygit="lazygit -ucd $HOME/.config/lazygit"
alias gitdf='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias lazygitdf="lazygit -ucd $HOME/.config/lazygit --git-dir=$HOME/.cfg --work-tree=$HOME"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

export PATH=$PATH:~/.cargo/bin

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f ~/.config/.dart-cli-completion/zsh-config.zsh ]] && . ~/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""
export PATH="$HOME/.local/bin:$PATH"
