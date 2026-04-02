#!/bin/bash
# Xiaoyuzhou Podcast Transcription Script
# Usage: bash transcribe.sh <xiaoyuzhou_episode_url> [output_file]
# Requires: GROQ_API_KEY (or configured via agent-search configure groq-key)

set -e

URL=${1:?Usage: bash transcribe.sh <xiaoyuzhou_episode_url> [output_file]}
OUTPUT="${2:-/tmp/podcast_transcript.txt}"
TMPDIR="/tmp/xiaoyuzhou_$$"

# Try env var first, then agent-search config.yaml
if [ -z "$GROQ_API_KEY" ]; then
    CONFIG_FILE="$HOME/.agent-search/config.yaml"
    if [ -f "$CONFIG_FILE" ]; then
        GROQ_API_KEY=$(python3 -c "import yaml; print((yaml.safe_load(open('$CONFIG_FILE')) or {}).get('groq_api_key',''))" 2>/dev/null || true)
    fi
fi
GROQ_API_KEY=${GROQ_API_KEY:?GROQ_API_KEY not set. Run: agent-search configure groq-key gsk_...}

# Groq API limit: 25MB per file — split into 20MB chunks to be safe
MAX_CHUNK_SIZE_MB=20
AUDIO_BITRATE="64k"

cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

mkdir -p "$TMPDIR"

echo "📻 Xiaoyuzhou Podcast Transcription"
echo "===================="

# Step 1: Fetch episode URL and title
echo "🔍 Fetching episode info..."
PAGE=$(curl -s "$URL")
AUDIO_URL=$(echo "$PAGE" | grep -oP 'https://media\.xyzcdn\.net/[^"]*\.(m4a|mp3)' | head -1)
TITLE=$(echo "$PAGE" | grep -oP '"title":"[^"]*"' | head -1 | sed 's/"title":"//;s/"//')

if [ -z "$AUDIO_URL" ]; then
    echo "❌ Could not extract audio URL from episode page"
    exit 1
fi

echo "📝 Title: $TITLE"
echo "🔗 Audio URL: $AUDIO_URL"

# Step 2: Download audio
echo "⬇️  Downloading audio..."
EXT="${AUDIO_URL##*.}"
curl -sL -o "$TMPDIR/original.$EXT" "$AUDIO_URL"
FILE_SIZE=$(ls -lh "$TMPDIR/original.$EXT" | awk '{print $5}')
echo "📦 Downloaded: $FILE_SIZE"

# Step 3: Get duration
DURATION=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$TMPDIR/original.$EXT" 2>/dev/null | cut -d. -f1)
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))
echo "⏱️  Duration: ${DURATION_MIN}m ${DURATION_SEC}s"

# Step 4: Convert to mono MP3
echo "🔄 Converting to mono MP3..."
ffmpeg -y -i "$TMPDIR/original.$EXT" -b:a "$AUDIO_BITRATE" -ac 1 "$TMPDIR/mono.mp3" 2>/dev/null
MONO_SIZE=$(stat -c%s "$TMPDIR/mono.mp3" 2>/dev/null || stat -f%z "$TMPDIR/mono.mp3")
echo "📦 Converted size: $(echo $MONO_SIZE / 1024 / 1024 | bc)MB"

# Step 5: Split into chunks if needed
MAX_BYTES=$((MAX_CHUNK_SIZE_MB * 1024 * 1024))

if [ "$MONO_SIZE" -le "$MAX_BYTES" ]; then
    cp "$TMPDIR/mono.mp3" "$TMPDIR/chunk_0.mp3"
    NUM_CHUNKS=1
    echo "📎 Single chunk (no splitting needed)"
else
    NUM_CHUNKS=$(( (MONO_SIZE / MAX_BYTES) + 1 ))
    CHUNK_DURATION=$(( DURATION / NUM_CHUNKS + 10 ))  # +10s overlap
    echo "✂️  Splitting into $NUM_CHUNKS chunks (~$((CHUNK_DURATION / 60))m each)..."

    for i in $(seq 0 $((NUM_CHUNKS - 1))); do
        START=$((i * CHUNK_DURATION))
        ffmpeg -y -i "$TMPDIR/mono.mp3" -ss "$START" -t "$CHUNK_DURATION" -c copy "$TMPDIR/chunk_${i}.mp3" 2>/dev/null
        CHUNK_SIZE=$(ls -lh "$TMPDIR/chunk_${i}.mp3" | awk '{print $5}')
        echo "  Chunk $((i+1))/$NUM_CHUNKS: $CHUNK_SIZE"
    done
fi

# Step 6: Transcribe each chunk via Groq Whisper API
echo "🎙️  Transcribing (Groq Whisper large-v3)..."

for i in $(seq 0 $((NUM_CHUNKS - 1))); do
    echo -n "  Chunk $((i+1))/$NUM_CHUNKS... "

    RESPONSE=$(curl -s -w "\n%{http_code}" \
        https://api.groq.com/openai/v1/audio/transcriptions \
        -H "Authorization: Bearer $GROQ_API_KEY" \
        -F file="@$TMPDIR/chunk_${i}.mp3" \
        -F model="whisper-large-v3" \
        -F language="zh" \
        -F response_format="text")

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" != "200" ]; then
        echo "❌ API Error (HTTP $HTTP_CODE)"
        echo "$BODY"

        if [ "$HTTP_CODE" = "429" ]; then
            # Rate limited — wait and retry
            WAIT_SEC=$(echo "$BODY" | grep -oP 'in \K[0-9]+m' | sed 's/m//' | head -1)
            WAIT_SEC=${WAIT_SEC:-2}
            WAIT_SEC=$((WAIT_SEC * 60 + 30))
            echo "⏳ Rate limited — waiting ${WAIT_SEC}s before retry..."
            sleep "$WAIT_SEC"
            RESPONSE=$(curl -s -w "\n%{http_code}" \
                https://api.groq.com/openai/v1/audio/transcriptions \
                -H "Authorization: Bearer $GROQ_API_KEY" \
                -F file="@$TMPDIR/chunk_${i}.mp3" \
                -F model="whisper-large-v3" \
                -F language="zh" \
                -F response_format="text")
            HTTP_CODE=$(echo "$RESPONSE" | tail -1)
            BODY=$(echo "$RESPONSE" | sed '$d')

            if [ "$HTTP_CODE" != "200" ]; then
                echo "❌ Retry failed"
                exit 1
            fi
        else
            exit 1
        fi
    fi

    echo "$BODY" > "$TMPDIR/transcript_${i}.txt"
    CHARS=$(wc -m < "$TMPDIR/transcript_${i}.txt")
    echo "✅ ($CHARS characters)"
done

# Step 7: Combine transcripts into final output
echo "📄 Writing output file..."

{
    echo "# $TITLE"
    echo ""
    echo "Source: $URL"
    echo "Duration: ${DURATION_MIN}m ${DURATION_SEC}s"
    echo "Transcribed: $(date '+%Y-%m-%d %H:%M')"
    echo ""
    echo "---"
    echo ""

    for i in $(seq 0 $((NUM_CHUNKS - 1))); do
        cat "$TMPDIR/transcript_${i}.txt"
        echo ""
    done
} > "$OUTPUT"

TOTAL_CHARS=$(wc -m < "$OUTPUT")
echo ""
echo "✅ Transcription complete!"
echo "📄 Output: $OUTPUT"
echo "📊 Total characters: $TOTAL_CHARS"
echo "===================="
