#!/bin/zsh
# Read-only network/HTTP monitor for an SV08 Max.
# Usage: ./monitor_eddy_ng.sh YOUR_PRINTER_IP

set -u

if (( $# < 1 )); then
  print -u2 "Usage: $0 PRINTER_IP"
  exit 2
fi

TARGET_IP="$1"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-30}"
LOG_DIR="${LOG_DIR:-./logs}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/eddy-ng-monitor.log}"
STATE_FILE="${STATE_FILE:-$LOG_DIR/eddy-ng-monitor.state}"
HTTP_URL="${HTTP_URL:-http://$TARGET_IP/}"
HTTP_TIMEOUT="${HTTP_TIMEOUT:-5}"
EXPECTED_HTTP_CODE="${EXPECTED_HTTP_CODE:-200}"

mkdir -p "$LOG_DIR"

timestamp() { date +"%Y-%m-%d %H:%M:%S %Z"; }
log_line() { printf "%s [%s] %s\n" "$(timestamp)" "$1" "$2" | tee -a "$LOG_FILE"; }

last_state="unknown"
[[ -f "$STATE_FILE" ]] && last_state="$(<"$STATE_FILE")"

while true; do
  if ping -c 1 "$TARGET_IP" >/dev/null 2>&1; then
    code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time "$HTTP_TIMEOUT" "$HTTP_URL" 2>/dev/null)"
    if [[ "$code" == "$EXPECTED_HTTP_CODE" ]]; then
      state="healthy"
    else
      state="degraded"
    fi
  else
    code="skipped"
    state="down"
  fi

  if [[ "$state" != "$last_state" ]]; then
    log_line INFO "State change: $last_state -> $state (HTTP $code)"
  else
    log_line INFO "Heartbeat: $state (HTTP $code)"
  fi
  print -r -- "$state" > "$STATE_FILE"
  last_state="$state"
  sleep "$INTERVAL_SECONDS"
done
