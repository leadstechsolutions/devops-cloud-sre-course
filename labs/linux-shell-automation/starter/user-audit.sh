#!/usr/bin/env bash
#
# user-audit.sh — list human (login) users and flag who has sudo access.
#
# "Human" users are those in /etc/passwd with UID >= UID_MIN (default 1000) and
# below the nobody sentinel (65534), excluding the typical service accounts.
# Sudo membership is determined from the 'sudo' and 'wheel' groups in /etc/group.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

UID_MIN=1000
PASSWD_FILE="/etc/passwd"
GROUP_FILE="/etc/group"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [-m|--min-uid N] [-p PASSWD_FILE] [-g GROUP_FILE] [-h|--help]

Lists human login accounts (UID >= min-uid, excluding nobody) from PASSWD_FILE
and marks which ones are in a sudo-granting group (sudo or wheel) per GROUP_FILE.

Options:
  -m, --min-uid N   Minimum UID treated as a human user. Default: ${UID_MIN}.
  -p FILE           passwd-format file to read. Default: ${PASSWD_FILE}.
  -g FILE           group-format file to read.  Default: ${GROUP_FILE}.
  -h, --help        Show this help and exit.

Output columns:  UID  USER  SHELL  SUDO(yes|no)

Example (audit the live host):
  $(basename "$0")
Example (audit a captured passwd file):
  $(basename "$0") -p ./fixtures/passwd -g ./fixtures/group
EOF
}

ARGS=()
while (($#)); do
  case "$1" in
    --min-uid) ARGS+=("-m"); shift ;;
    --min-uid=*) ARGS+=("-m" "${1#*=}"); shift ;;
    --help) ARGS+=("-h"); shift ;;
    --) shift; while (($#)); do ARGS+=("$1"); shift; done ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

while getopts ":m:p:g:h" opt; do
  case "$opt" in
    m) UID_MIN="$OPTARG" ;;
    p) PASSWD_FILE="$OPTARG" ;;
    g) GROUP_FILE="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) die "option -$OPTARG requires an argument" ;;
    \?) usage; die "unknown option: -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

if ! [[ "$UID_MIN" =~ ^[0-9]+$ ]]; then
  die "--min-uid must be a non-negative integer (got: '$UID_MIN')"
fi
[[ -r "$PASSWD_FILE" ]] || die "cannot read passwd file: $PASSWD_FILE"
[[ -r "$GROUP_FILE" ]]  || die "cannot read group file: $GROUP_FILE"

require_cmd awk sort

# --- collect sudoers --------------------------------------------------------
# Group file format: name:passwd:gid:member1,member2,...
# The 4th field of the sudo/wheel lines lists supplementary members. We build a
# set of usernames that are members of either group.
declare -A IS_SUDO=()
while IFS=: read -r gname _ _ members; do
  case "$gname" in
    sudo|wheel|admin) ;;
    *) continue ;;
  esac
  # Split the comma-separated member list.
  IFS=',' read -r -a marr <<<"$members"
  for u in "${marr[@]}"; do
    [[ -n "$u" ]] && IS_SUDO["$u"]=1
  done
done <"$GROUP_FILE"

# --- list human users -------------------------------------------------------
# passwd format: name:passwd:uid:gid:gecos:home:shell
# Keep UID >= UID_MIN and != 65534 (nobody). Print sorted by UID.
human_count=0
sudo_count=0

printf '%-7s %-20s %-20s %s\n' "UID" "USER" "SHELL" "SUDO"
while IFS=: read -r uname _ uid _ _ _ ushell; do
  [[ "$uid" =~ ^[0-9]+$ ]] || continue
  # TODO(student): keep only HUMAN accounts. A human account has UID >= UID_MIN
  # AND is not the 'nobody' sentinel (UID 65534). `continue` past anything else
  # BEFORE counting it. (Two guard lines.)

  human_count=$((human_count + 1))

  # TODO(student): set `sudo` to "yes" if this user appears in the IS_SUDO set
  # built above (key = "$uname"), otherwise "no". When yes, also bump sudo_count.
  sudo="no"   # TODO(student): replace with the real check

  printf '%-7s %-20s %-20s %s\n' "$uid" "$uname" "$ushell" "$sudo"
done < <(sort -t: -k3 -n "$PASSWD_FILE")

log "INFO" "audited ${human_count} human user(s); ${sudo_count} with sudo"
exit 0
