cap() {
  if [ -z "$1" ]; then
    echo "Utility to capture ad hoc notes. Enter cap <your_note>"
    return 1
  fi

  PROJECT=$(tmux display-message -p '#S' | awk -F'-' '{print $1}' 2>/dev/null || echo "inbox")
  FILE="${NOTES_DIR:-$HOME}/$PROJECT/log.md"
  mkdir -p "$(dirname "$FILE")"
  echo "- [$(date '+%Y-%m-%d %H:%M')] $@" >> "$FILE"
  echo "✓ Added to $PROJECT"
}

caplist() {
  local n=${1:-10}
  local PROJECT=$(tmux display-message -p '#S' | awk -F'-' '{print $1}' 2>/dev/null || echo "inbox")
  local FILE="${NOTES_DIR:-$HOME}/$PROJECT/log.md"

  if [ ! -f "$FILE" ]; then
    echo "No log file found for project: $PROJECT"
    return 1
  fi

  echo -e "\033[1;34m=== Last $n logs for $PROJECT ===\033[0m"
  tail -n "$n" "$FILE"
}

capfind() {
  local PROJECT=$(tmux display-message -p '#S' | awk -F'-' '{print $1}' 2>/dev/null || echo "inbox")
  local FILE="${NOTES_DIR:-$HOME}/$PROJECT/log.md"

  if [ -f "$FILE" ]; then
    grep -i --color=auto "$1" "$FILE"
  else
    echo "No log found for $PROJECT"
  fi
}

