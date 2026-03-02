#!/usr/bin/env bash
set -euo pipefail

# nix shell nixpkgs#{poppler_utils,imagemagick,img2pdf,mozjpeg}

# Tunables
QUALITY="${QUALITY:-82}"        # 80-85 is sane for photos+diagrams
MAXPX="${MAXPX:-2800}"          # long-edge cap; 2800 ~= ~240-260 DPI for your pages
OUTSUFFIX="${OUTSUFFIX:-}"      # output: ./small/input.pdf
OUTDIR="${OUTDIR:-small}"
mkdir -p "$OUTDIR"

usage() {
  cat <<'EOF'

compress_pdf_images.sh makes smaller PDFs from scanned PDFs
(where each page is a JPEG wrapped in a PDF). It does this by:

  1) Extracts the embedded JPEG page images (pdfimages)
  2) Optionally downsamples large pages (magick) to reduce resolution
  3) Recompresses the JPEGs to a chosen quality (prefers cjpeg from mozjpeg)
  4) Reassembles the pages into a new PDF (img2pdf)

Usage:
  compress_pdf_images.sh [pdf1.pdf pdf2.pdf ...]

Environment variables:
  QUALITY=82      JPEG quality (higher = larger + better)
  MAXPX=2800      Max long-edge pixels (lower = smaller + more loss)
  OUTSUFFIX=      Output suffix (input.OUTSUFFIX.pdf)
  OUTDIR=small    Output directory (default: ./small)

Examples:
  QUALITY=82 MAXPX=2800 ./compress_pdf_images.sh test.pdf
  QUALITY=80 MAXPX=2400 OUTDIR=. OUTSUFFIX=small ./compress_pdf_images.sh test.pdf

EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

# If no args: try all PDFs
PDFS=("$@")
if [[ ${#PDFS[@]} -eq 0 ]]; then
  shopt -s nullglob
  PDFS=( *.pdf )
  shopt -u nullglob
fi

if [[ ${#PDFS[@]} -eq 0 ]]; then
  echo "No PDFs found."
  exit 1
fi

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1"; exit 1; }; }

need_cmd pdfimages
need_cmd magick
need_cmd img2pdf

has_cjpeg=0
if command -v cjpeg >/dev/null 2>&1; then
  has_cjpeg=1
fi

for pdf in "${PDFS[@]}"; do
  [[ -f "$pdf" ]] || continue
  echo "compressing $pdf"

  base="$(basename "$pdf")"
  stem="${base%.pdf}"
  if [[ -n "$OUTSUFFIX" ]]; then
    out="$OUTDIR/${stem}.${OUTSUFFIX}.pdf"
  else
    out="$OUTDIR/${stem}.pdf"
  fi

  tmp="$(mktemp -d)"
  mkdir -p "$tmp/out"

  # 1) Extract embedded JPEGs (CamScanner-style PDFs are perfect for this)
  pdfimages -all "$pdf" "$tmp/page" >/dev/null

  # Ensure we have images
  shopt -s nullglob
  imgs=( "$tmp"/page-*.jpg )
  shopt -u nullglob
  if [[ ${#imgs[@]} -eq 0 ]]; then
    echo "No JPEGs extracted from $pdf (unexpected). Skipping."
    rm -rf "$tmp"
    continue
  fi

  # 2) Downsample (only if larger than MAXPX) + recompress
  for f in "${imgs[@]}"; do
    base="$(basename "$f")"
    resized="$tmp/resized-$base"
    outjpg="$tmp/out/$base"

    # Resize only if needed; keep aspect; do NOT enlarge
    magick "$f" -auto-orient -resize "${MAXPX}x${MAXPX}>" -strip "$resized"

    if [[ $has_cjpeg -eq 1 ]]; then
      # mozjpeg encoder: usually best size/quality
      cjpeg -quality "$QUALITY" -optimize -progressive -outfile "$outjpg" "$resized"
    else
      # Fallback: ImageMagick JPEG encoder
      magick "$resized" -interlace Plane -quality "$QUALITY" "$outjpg"
    fi
  done

  # 3) Reassemble to PDF (page-000.jpg ... keeps correct order)
  img2pdf "$tmp/out/"page-*.jpg -o "$out"

  rm -rf "$tmp"

  echo "Wrote: $out"
done
