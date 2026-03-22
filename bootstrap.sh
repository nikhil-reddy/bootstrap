#!/usr/bin/env bash
set -euo pipefail

# Minimal terminal bootstrap for macOS (Homebrew) and Debian/Ubuntu (apt)
# Usage:
#   bash bootstrap.sh
# Optional toggles (set to 1 to enable):
#   INSTALL_TERRAFORM=1
#   INSTALL_STARSHIP=1
#   INSTALL_FONTS=1
#   INSTALL_TFENV=1
#   INSTALL_CODEX_SKILLS=1
#   CONFIGURE_GIT=1
#   CONFIGURE_ZSH=1
#   CONFIGURE_STARSHIP=1
#   INSTALL_TOOLS=1 (default on)

INSTALL_TOOLS=${INSTALL_TOOLS:-1}
INSTALL_TERRAFORM=${INSTALL_TERRAFORM:-1}
INSTALL_STARSHIP=${INSTALL_STARSHIP:-1}
INSTALL_FONTS=${INSTALL_FONTS:-0}
INSTALL_TFENV=${INSTALL_TFENV:-1}
INSTALL_CODEX_SKILLS=${INSTALL_CODEX_SKILLS:-1}
CONFIGURE_GIT=${CONFIGURE_GIT:-1}
CONFIGURE_ZSH=${CONFIGURE_ZSH:-1}
CONFIGURE_STARSHIP=${CONFIGURE_STARSHIP:-1}

BREW_BIN="/opt/homebrew/bin/brew"
BREW_BIN_INTEL="/usr/local/bin/brew"

log() { printf "[bootstrap] %s\n" "$*"; }

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

is_debian() {
  [[ -f /etc/os-release ]] && . /etc/os-release && [[ "${ID:-}" == "debian" || "${ID_LIKE:-}" == *"debian"* || "${ID:-}" == "ubuntu" || "${ID_LIKE:-}" == *"ubuntu"* ]]
}

ensure_command() {
  command -v "$1" >/dev/null 2>&1
}

ensure_block() {
  # Usage: ensure_block <file> <marker> <content>
  local file="$1" marker="$2" content="$3"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -q "${marker}" "$file"; then
    {
      printf "\n# %s\n" "$marker"
      printf "%s\n" "$content"
      printf "# end %s\n" "$marker"
    } >> "$file"
  fi
}

install_brew() {
  if ensure_command brew; then
    return
  fi

  log "Homebrew not found; installing."
  # Official installer from Homebrew (macOS) - minimal and standard
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x "$BREW_BIN" ]]; then
    eval "\"$BREW_BIN\" shellenv"
  elif [[ -x "$BREW_BIN_INTEL" ]]; then
    eval "\"$BREW_BIN_INTEL\" shellenv"
  fi
}

install_packages_macos() {
  install_brew

  local pkgs=(git zsh fzf ripgrep fd bat eza zoxide zsh-autosuggestions zsh-syntax-highlighting)
  if [[ "$INSTALL_STARSHIP" == "1" ]]; then
    pkgs+=(starship)
  fi

  log "Installing packages via Homebrew: ${pkgs[*]}"
  brew install "${pkgs[@]}"

  if [[ "$INSTALL_TERRAFORM" == "1" ]]; then
    log "Installing terraform via Homebrew"
    brew install terraform
  fi

  if [[ "$INSTALL_FONTS" == "1" ]]; then
    log "Installing RobotoMono Nerd Font via Homebrew cask"
    brew install --cask font-roboto-mono-nerd-font
  fi

  if [[ "$INSTALL_TFENV" == "1" ]]; then
    log "Installing tfenv via Homebrew"
    brew install tfenv
  fi
}

install_packages_debian() {
  sudo apt-get update

  local pkgs=(git zsh fzf ripgrep fd-find bat eza zoxide)
  log "Installing packages via apt: ${pkgs[*]}"
  sudo apt-get install -y "${pkgs[@]}"

  log "Installing zsh plugins via apt (if available)"
  if apt-cache show zsh-autosuggestions >/dev/null 2>&1; then
    sudo apt-get install -y zsh-autosuggestions
  else
    log "zsh-autosuggestions not found in apt; skipping"
  fi
  if apt-cache show zsh-syntax-highlighting >/dev/null 2>&1; then
    sudo apt-get install -y zsh-syntax-highlighting
  else
    log "zsh-syntax-highlighting not found in apt; skipping"
  fi

  if [[ "$INSTALL_STARSHIP" == "1" ]]; then
    log "Installing starship via apt (if available)"
    if apt-cache show starship >/dev/null 2>&1; then
      sudo apt-get install -y starship
    else
      log "starship not found in apt; skipping"
    fi
  fi

  if [[ "$INSTALL_TERRAFORM" == "1" ]]; then
    # HashiCorp official repo
    log "Installing terraform from HashiCorp official apt repo"
    sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y terraform
  fi

  if [[ "$INSTALL_FONTS" == "1" ]]; then
    log "Installing RobotoMono Nerd Font (download from Nerd Fonts)"
    sudo apt-get install -y curl unzip fontconfig
    mkdir -p "$HOME/.local/share/fonts"
    tfile="/tmp/RobotoMono.zip"
    curl -fsSL -o "$tfile" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/RobotoMono.zip"
    unzip -o "$tfile" -d "$HOME/.local/share/fonts" >/dev/null
    rm -f "$tfile"
    fc-cache -f "$HOME/.local/share/fonts"
  fi

  if [[ "$INSTALL_TFENV" == "1" ]]; then
    log "Installing tfenv (git clone)"
    sudo apt-get install -y git
    if [[ ! -d "$HOME/.tfenv" ]]; then
      git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
    fi
  fi

  # Debian/Ubuntu package name differences
  # fd -> fd-find provides `fdfind` binary
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    log "Creating fd symlink for Debian/Ubuntu (fdfind -> fd)"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  # bat binary is `batcat`
  if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    log "Creating bat symlink for Debian/Ubuntu (batcat -> bat)"
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
}

configure_git() {
  log "Configuring git defaults"
  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global rebase.autoStash true
  git config --global fetch.prune true
  git config --global diff.algorithm histogram
  git config --global merge.conflictstyle diff3
  git config --global push.default simple

  # Useful aliases (safe, non-destructive)
  git config --global alias.st "status -sb"
  git config --global alias.br "branch -vv"
  git config --global alias.co "checkout"
  git config --global alias.ci "commit"
  git config --global alias.last "log -1 --stat"
  git config --global alias.lg "log --graph --decorate --oneline --all"
  git config --global alias.fixup "commit --fixup"
}

configure_zsh() {
  log "Configuring zsh defaults (backup + overwrite)"
  local zshrc="$HOME/.zshrc"
  if [[ -f "$zshrc" ]]; then
    local backup="${zshrc}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$zshrc" "$backup"
    log "Backed up existing .zshrc to $backup"
  fi

  cat > "$zshrc" <<'EOF'
# Minimal zsh config (managed by bootstrap.sh)

# Ensure local bin first (for fd/bat symlinks on Debian/Ubuntu)
export PATH="$HOME/.local/bin:$PATH"

# History: fast, deduped, shared
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

# Initialize zsh completion system before any completion scripts use compdef
autoload -U compinit
mkdir -p ~/.zsh/cache
compinit -d ~/.zsh/cache/zcompdump

# Completion cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' rehash true

# Ghost text autosuggestions and syntax highlighting
if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Prefix search with Up/Down
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# FZF defaults
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=never --level=2 {}'"

rgf() {
  rg --line-number --no-heading --color=always --smart-case "$@" \
    | fzf --ansi --delimiter : --nth 2.. --preview 'bat --color=always --highlight-line {2} {1}' \
    | awk -F: '{print $1 ":" $2}'
}

# Optional tools
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"

# Tool completions (only if installed)
command -v kubectl >/dev/null && source <(kubectl completion zsh)
command -v docker >/dev/null && source <(docker completion zsh)
if command -v terraform >/dev/null; then
  terraform -install-autocomplete >/dev/null 2>&1 || true
fi

# Auto-switch Terraform version if .terraform-version exists and tfenv is installed
_tfenv_auto_use() {
  if command -v tfenv >/dev/null; then
    if [[ -f .terraform-version ]]; then
      local v
      v=$(< .terraform-version)
      tfenv install "$v" >/dev/null 2>&1 || true
      tfenv use "$v" >/dev/null 2>&1 || true
    fi
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd _tfenv_auto_use
_tfenv_auto_use
EOF
}

configure_starship() {
  local cfg_dir="$HOME/.config"
  local cfg="$cfg_dir/starship.toml"
  if [[ -f "$cfg" ]]; then
    return
  fi
  mkdir -p "$cfg_dir"
  cat > "$cfg" <<'EOF'
# Minimal Starship prompt config
add_newline = false
format = "$username$hostname$directory$git_branch$git_status$cmd_duration$character"

[username]
show_always = true
style_user = "bold fg:37"
style_root = "bold fg:160"
format = "[$user]($style)"

[hostname]
ssh_only = false
style = "bold fg:37"
format = "@[$hostname]($style) "

[directory]
style = "bold fg:37"
format = "[$path]($style) "
truncation_length = 3
truncate_to_repo = false

[git_branch]
style = "bold fg:208"
format = "[$symbol$branch]($style) "

[git_status]
style = "fg:208"
format = "[$all_status$ahead_behind]($style) "

[cmd_duration]
min_time = 4000
format = "[took $duration]($style) "
style = "bold fg:244"

[character]
success_symbol = "[❯](fg:250)"
error_symbol = "[❯](fg:160)"
EOF
}

install_codex_skills() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local src="${script_dir}/.agents/skills"
  local dst="$HOME/.agents/skills"
  if [[ ! -d "$src" ]]; then
    log "No skills found at $src"
    return
  fi
  mkdir -p "$dst"
  cp -R "$src/." "$dst/"
  log "Installed Codex skills to $dst"
}

main() {
  if [[ "$INSTALL_TOOLS" == "1" ]]; then
    if is_macos; then
      install_packages_macos
    elif is_debian; then
      install_packages_debian
    else
      log "Unsupported OS. Only macOS and Debian/Ubuntu are supported."
      exit 1
    fi
  fi

  if [[ "$CONFIGURE_GIT" == "1" ]]; then
    configure_git
  fi

  if [[ "$CONFIGURE_ZSH" == "1" ]]; then
    configure_zsh
  fi

  if [[ "$CONFIGURE_STARSHIP" == "1" ]]; then
    configure_starship
  fi

  if [[ "$INSTALL_CODEX_SKILLS" == "1" ]]; then
    install_codex_skills
  fi

  log "Done. Restart your shell to pick up zsh changes."
}

main "$@"
