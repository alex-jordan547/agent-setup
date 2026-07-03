# agent-setup shell snippet — source from ~/.zshrc / ~/.bashrc:
#   source ~/Documents/Developper/agent-setup/shell/env.sh

# chrome-cdp: under WSL, Chrome runs on the Windows side; point the skill at
# its DevToolsActivePort. On macOS/Linux the skill auto-detects the profile.
if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
  export CDP_PORT_FILE="/mnt/c/Users/Alex Jordan/AppData/Local/Google/Chrome/User Data/DevToolsActivePort"
fi

# Terminal QoL — each line no-ops if the tool isn't installed on this machine.
if [ -n "${ZSH_VERSION:-}" ]; then
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"   # z <dir> = cd intelligent
  command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"   # .envrc par projet
  command -v fzf    >/dev/null 2>&1 && source <(fzf --zsh)         # Ctrl-R/Ctrl-T/Alt-C
fi
