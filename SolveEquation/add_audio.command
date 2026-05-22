#!/bin/bash
# Generate AI voice with Google Cloud TTS and merge into SolveEquation.mp4

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

VIDEO="$SCRIPT_DIR/media/videos/GEDLecture1/1080p60/SolveEquation.mp4"
AUDIO_MP3="$SCRIPT_DIR/narration.mp3"
OUTPUT="$SCRIPT_DIR/SolveEquation_with_audio.mp4"
API_KEY="YOUR_GOOGLE_CLOUD_API_KEY"
TTS_URL="https://texttospeech.googleapis.com/v1/text:synthesize?key=$API_KEY"

NARRATION="Let's solve the equation: x plus 10 equals 5. \
To isolate x, we subtract 10 from both sides. \
On the left, positive 10 and negative 10 cancel out, leaving x. \
On the right, 5 minus 10 equals negative 5. \
Therefore, x equals negative 5. \
Thank you, and see you next!"

echo "================================================"
echo " Step 1: Generating AI voice (en-US-Studio-O)..."
echo "================================================"

# Call Google Cloud TTS API (using SSML for trailing silence)
SSML="<speak>${NARRATION}<break time='2s'/></speak>"

RESPONSE=$(curl -s -X POST "$TTS_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"input\": {\"ssml\": \"$SSML\"},
    \"voice\": {
      \"languageCode\": \"en-US\",
      \"name\": \"en-US-Studio-O\"
    },
    \"audioConfig\": {
      \"audioEncoding\": \"MP3\",
      \"speakingRate\": 0.95,
      \"pitch\": 0
    }
  }")

# Check for errors
if echo "$RESPONSE" | grep -q "error"; then
  echo "API Error:"
  echo "$RESPONSE"
  exit 1
fi

# Decode base64 audio to MP3
echo "$RESPONSE" | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
audio = base64.b64decode(data['audioContent'])
with open('$AUDIO_MP3', 'wb') as f:
    f.write(audio)
print('Audio saved: $AUDIO_MP3')
"

echo ""
echo "================================================"
echo " Step 2: Merging AI audio + video with ffmpeg..."
echo "================================================"

ffmpeg -y \
  -i "$VIDEO" \
  -i "$AUDIO_MP3" \
  -map 0:v \
  -map 1:a \
  -c:v copy \
  -c:a aac \
  -shortest \
  "$OUTPUT"

echo ""
if [ -f "$OUTPUT" ]; then
  echo "================================================"
  echo " Done! Saved to:"
  echo " $OUTPUT"
  echo "================================================"
  rm -f "$AUDIO_MP3"
  open "$OUTPUT"
else
  echo "Something went wrong. Check output above."
fi
