# agent-setup shell snippet — source from ~/.zshrc / ~/.bashrc:
#   source ~/Documents/Developper/agent-setup/shell/env.sh

# chrome-cdp: under WSL, Chrome runs on the Windows side; point the skill at
# its DevToolsActivePort. On macOS/Linux the skill auto-detects the profile.
if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
  export CDP_PORT_FILE="/mnt/c/Users/Alex Jordan/AppData/Local/Google/Chrome/User Data/DevToolsActivePort"
fi
