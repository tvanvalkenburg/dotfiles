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

_tcap_resolve() {
  if [ -z "$TEAM_NOTES_DIR" ]; then
    echo "TEAM_NOTES_DIR is not set" >&2
    return 1
  fi
  local q="$1"
  local matches=("$TEAM_NOTES_DIR"/${q}*.md(N))
  if (( ${#matches[@]} == 0 )); then
    echo "No team member matches '$q'. Available:" >&2
    print -l "$TEAM_NOTES_DIR"/*.md(:t:r) >&2
    return 1
  elif (( ${#matches[@]} > 1 )); then
    echo "Ambiguous '$q'. Matches:" >&2
    print -l "${matches[@]:t:r}" >&2
    return 1
  fi
  print -r -- "${matches[1]}"
}

tcap() {
  if [ -z "$1" ]; then
    echo "Usage: tcap [person] <note>  (no person → inbox.md)"
    return 1
  fi
  if [ -z "$TEAM_NOTES_DIR" ]; then
    echo "TEAM_NOTES_DIR is not set" >&2
    return 1
  fi
  local file
  local matches=("$TEAM_NOTES_DIR"/${1}*.md(N))
  if (( ${#matches[@]} > 1 )); then
    echo "Ambiguous person prefix '$1'. Matches:" >&2
    print -l "${matches[@]:t:r}" >&2
    return 1
  elif (( ${#matches[@]} == 1 )) && [ -n "$2" ]; then
    file="${matches[1]}"
    shift
  else
    file="$TEAM_NOTES_DIR/inbox.md"
  fi
  echo "- [$(date '+%Y-%m-%d %H:%M')] $@" >> "$file"
  echo "✓ Added to ${file:t:r}"
}

tcaplist() {
  if [ -z "$TEAM_NOTES_DIR" ]; then
    echo "TEAM_NOTES_DIR is not set" >&2
    return 1
  fi
  local file n
  if [ -z "$1" ] || [[ "$1" =~ '^[0-9]+$' ]]; then
    file="$TEAM_NOTES_DIR/inbox.md"
    n=${1:-10}
  else
    file=$(_tcap_resolve "$1") || return 1
    n=${2:-10}
  fi
  if [ ! -f "$file" ]; then
    echo "No log file: $file"
    return 1
  fi
  echo -e "\033[1;34m=== Last $n notes for ${file:t:r} ===\033[0m"
  tail -n "$n" "$file"
}

tcapfind() {
  if [ -z "$2" ]; then
    grep -in --color=auto "$1" "$TEAM_NOTES_DIR"/*.md
  else
    local file; file=$(_tcap_resolve "$1") || return 1
    grep -in --color=auto "$2" "$file"
  fi
}

