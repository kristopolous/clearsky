{ pkgs }:

pkgs.writeShellScriptBin "google-photos-download" ''
  set -e

  API_KEY=""
  OUTPUT_DIR=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --api-key)
        API_KEY="$2"
        shift 2
        ;;
      --output)
        OUTPUT_DIR="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  if [ -z "$API_KEY" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: google-photos-download --api-key KEY --output DIR"
    exit 1
  fi

  mkdir -p "$OUTPUT_DIR"

  echo "Downloading photos from Google Photos API..."

  # Use google-photos-takeout or gphotos-sync if available
  # For now, use curl with the Google Photos Library API
  
  BASE_URL="https://photoslibrary.googleapis.com"
  
  # Get media items
  PAGE_TOKEN=""
  while true; do
    if [ -n "$PAGE_TOKEN" ]; then
      RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
        "$BASE_URL/v1/mediaItems?pageSize=100&pageToken=$PAGE_TOKEN")
    else
      RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
        "$BASE_URL/v1/mediaItems?pageSize=100")
    fi

    # Parse and download each media item
    echo "$RESPONSE" | jq -r '.mediaItems[]? | "\(.id)\t\(.filename)\t\(.productUrl)"' | while IFS=$'\t' read -r id filename url; do
      if [ -n "$filename" ]; then
        echo "Downloading: $filename"
        curl -L -H "Authorization: Bearer $API_KEY" "$url" -o "$OUTPUT_DIR/$filename"
      fi
    done

    # Check for next page
    PAGE_TOKEN=$(echo "$RESPONSE" | jq -r '.nextPageToken // empty')
    if [ -z "$PAGE_TOKEN" ]; then
      break
    fi
  done

  echo "Download complete to $OUTPUT_DIR"
''
