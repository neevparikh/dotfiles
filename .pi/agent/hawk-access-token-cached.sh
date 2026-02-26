#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/pi-agent"
CACHE_FILE="$CACHE_DIR/hawk-access-token"
LOCK_FILE="$CACHE_DIR/hawk-access-token.lock"
TTL_SECONDS=$((16 * 60 * 60))

mkdir -p "$CACHE_DIR"

print_cached_token_if_fresh() {
  if [[ ! -f "$CACHE_FILE" ]]; then
    return 1
  fi

  local now mtime age
  now="$(date +%s)"

  if mtime="$(stat -f %m "$CACHE_FILE" 2>/dev/null)"; then
    :
  else
    mtime="$(stat -c %Y "$CACHE_FILE")"
  fi

  age=$((now - mtime))
  if ((age < TTL_SECONDS)); then
    local token
    token="$(<"$CACHE_FILE")"
    if [[ -n "$token" ]]; then
      printf '%s\n' "$token"
      return 0
    fi
  fi

  return 1
}

if print_cached_token_if_fresh; then
  exit 0
fi

exec 9>"$LOCK_FILE"
if command -v flock >/dev/null 2>&1; then
  flock 9
fi

if print_cached_token_if_fresh; then
  exit 0
fi

command=(
  uvx
  --from
  "hawk[cli,inspect] @ git+https://github.com/METR/inspect-action"
  hawk
  auth
  access-token
)

new_token="$("${command[@]}")"
if [[ -z "$new_token" ]]; then
  if [[ -f "$CACHE_FILE" ]]; then
    cached_token="$(<"$CACHE_FILE")"
    if [[ -n "$cached_token" ]]; then
      printf '%s\n' "$cached_token"
      exit 0
    fi
  fi
  echo "Failed to fetch access token and no cached token is available." >&2
  exit 1
fi

printf '%s\n' "$new_token" > "$CACHE_FILE"
chmod 600 "$CACHE_FILE"
printf '%s\n' "$new_token"
