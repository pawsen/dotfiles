#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  zip2pdf.sh                # convert all *.zip in current directory
  zip2pdf.sh FILE.zip [...] # convert only the specified zip(s)

Notes:
  - Produces one PDF per ZIP: <zipname>.pdf
  - Uses natural/version sort so ..._2.jpg comes before ..._10.jpg
EOF
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 127; }
}

need_cmd unzip
need_cmd find
need_cmd sort
need_cmd xargs
need_cmd img2pdf

shopt -s nullglob

# Build the list of ZIPs to process
zips=()
if (( $# == 0 )); then
  zips=( *.zip )
  if (( ${#zips[@]} == 0 )); then
    echo "No .zip files found in current directory." >&2
    exit 1
  fi
else
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
  esac

  for arg in "$@"; do
    if [[ "$arg" != *.zip ]]; then
      echo "Not a .zip file: $arg" >&2
      exit 2
    fi
    if [[ ! -f "$arg" ]]; then
      echo "File not found: $arg" >&2
      exit 2
    fi
    zips+=( "$arg" )
  done
fi

for z in "${zips[@]}"; do
  base="${z%.zip}"
  tmp="$(mktemp -d)"

  cleanup() { rm -rf "$tmp"; }
  trap cleanup EXIT

  unzip -q -- "$z" -d "$tmp"

  # Natural/version sort, NUL-safe
  find "$tmp" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 \
    | sort -z -V \
    | xargs -0 img2pdf -o "$base.pdf"

  rm -rf "$tmp"
  trap - EXIT
done
