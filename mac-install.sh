#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Mac Bootstrap: Homebrew + Brewfile + shell + git ssh + node (nvm) + CLIs
# -----------------------------------------------------------------------------

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE_PATH="${BREWFILE_PATH:-$ROOT_DIR/Brewfile}"
ZSHRC="${HOME}/.zshrc"

log()  { printf "\n\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\n\033[1;33m[warn]\033[0m %s\n" "$*"; }
die()  { printf "\n\033[1;31m[err]\033[0m %s\n" "$*"; exit 1; }

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This script is for macOS only."
}

install_xcode_cli_tools() {
  # Many brew installs require Command Line Tools.
  if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools..."
    xcode-select --install || true
    warn "If a GUI prompt appeared, complete it, then re-run this script."
  else
    log "Xcode Command Line Tools already installed."
  fi
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed."
    return
  fi

  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ensure brew is in PATH for this session + future shells
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    die "Brew installed but not found in expected locations."
  fi
}

ensure_brew_shellenv_in_zshrc() {
  log "Ensuring Homebrew shellenv is loaded in ~/.zshrc..."

  # Per Homebrew docs: eval "$(brew shellenv)" after ensuring PATH includes brew locations. :contentReference[oaicite:6]{index=6}
  local marker="# >>> homebrew shellenv >>>"
  if ! grep -qF "$marker" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" <<'EOF'

# >>> homebrew shellenv >>>
command -v brew >/dev/null 2>&1 || export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v brew >/dev/null 2>&1 && eval "$(brew shellenv)"
# <<< homebrew shellenv <<<
EOF
  fi

  # Load it now so the rest of the script can run in this session
  # shellcheck disable=SC1090
  source "$ZSHRC" || true
}

brew_bundle_install() {
  [[ -f "$BREWFILE_PATH" ]] || die "Brewfile not found at: $BREWFILE_PATH"

  log "Updating Homebrew..."
  brew update

  log "Installing from Brewfile with brew bundle..."
  # Brew Bundle docs: declarative installs via Brewfile. :contentReference[oaicite:7]{index=7}
  brew bundle --file "$BREWFILE_PATH"

  log "Cleaning up Homebrew..."
  brew cleanup
}

setup_git_ssh_key() {
  # Creates a GitHub key you can add to GitHub.
  # Uses ed25519 (modern default) and macOS keychain integration.
  local key_path="${HOME}/.ssh/id_ed25519_github"
  local email="${GIT_EMAIL:-rjain15@gmail.com}"

  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"

  if [[ -f "$key_path" ]]; then
    log "SSH key already exists: $key_path"
  else
    log "Creating SSH key (ed25519) for GitHub..."
    ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N ""
  fi

  # Add to ssh-agent + keychain
  eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
  ssh-add --apple-use-keychain "$key_path" >/dev/null 2>&1 || ssh-add "$key_path" || true

  # Ensure SSH config entry
  local ssh_config="${HOME}/.ssh/config"
  touch "$ssh_config"
  chmod 600 "$ssh_config"

  if ! grep -q "Host github.com" "$ssh_config"; then
    log "Adding GitHub SSH config to ~/.ssh/config..."
    cat >> "$ssh_config" <<EOF

# --- GitHub (personal) ---
Host github.com
  HostName github.com
  User git
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ${key_path}
EOF
  fi

  log "Copying public key to clipboard..."
  pbcopy < "${key_path}.pub"
  echo "✅ Public key copied. Paste it into GitHub > Settings > SSH and GPG keys."
}

setup_nvm_and_node() {
  # Install nvm via brew (from Brewfile) and configure zsh.
  # Homebrew formula exists. :contentReference[oaicite:8]{index=8}
  log "Configuring nvm in ~/.zshrc..."

  local marker="# >>> nvm >>>"
  if ! grep -qF "$marker" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" <<'EOF'

# >>> nvm >>>
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
# Homebrew installs nvm here:
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"
# <<< nvm <<<
EOF
  fi

  # Load nvm now
  # shellcheck disable=SC1090
  source "$ZSHRC" || true

  if command -v nvm >/dev/null 2>&1; then
    log "Installing latest Node LTS via nvm..."
    nvm install --lts
    nvm alias default 'lts/*'
    nvm use default
    log "Node: $(node -v) | npm: $(npm -v)"
  else
    warn "nvm not found in PATH yet. Open a new terminal and run: nvm install --lts"
  fi
}

install_global_npm_tools() {
  # Only installs after Node is available
  if ! command -v npm >/dev/null 2>&1; then
    warn "npm not found yet; skipping global npm tools (vercel)."
    return
  fi

  log "Installing global npm tools..."
  npm install -g vercel
}

post_install_notes() {
  log "Post-install notes:"
  echo "• VS Code: run 'Shell Command: Install \"code\" command in PATH' from the Command Palette if needed."
  echo "• Cursor: app is installed; CLI availability varies by version. If you want 'cursor' in PATH, check Cursor settings."
  echo "• AWS CLI installed via brew (awscli). :contentReference[oaicite:9]{index=9}"
  echo "• Brew Bundle manages installs declaratively via Brewfile. :contentReference[oaicite:10]{index=10}"
}

main() {
  require_macos
  install_xcode_cli_tools
  install_homebrew
  ensure_brew_shellenv_in_zshrc
  brew_bundle_install
  setup_git_ssh_key
  setup_nvm_and_node
  install_global_npm_tools
  post_install_notes

  log "Done ✅"
  echo "Restart your terminal (or 'source ~/.zshrc') to ensure everything is active."
}

main "$@"
