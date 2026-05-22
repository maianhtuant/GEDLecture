#!/bin/bash
# Generate TTS narration via Google Cloud TTS and merge into SolveEquation.mp4
# narration.wav is cached — delete it to force regeneration.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VIDEO="$SCRIPT_DIR/media/videos/GEDLecture1/1080p60/SolveEquation.mp4"
AUDIO_MP3="$SCRIPT_DIR/narration.mp3"
AUDIO_WAV="$SCRIPT_DIR/narration.wav"
OUTPUT="$SCRIPT_DIR/SolveEquation_with_audio.mp4"

# ── Paste your Google Cloud TTS API key here ──────────────────────────────────
GOOGLE_API_KEY="YOUR_GOOGLE_CLOUD_API_KEY"
TTS_URL="https://texttospeech.googleapis.com/v1/text:synthesize?key=$API_KEY"
# ─────────────────────────────────────────────────────────────────────────────

# Steps 1 & 2: Only generate audio if narration.wav doesn't exist yet
if [ ! -f "$AUDIO_WAV" ]; then
    echo "Step 1: Generating narration with Google Cloud TTS..."

    curl -s -X POST \
      "https://texttospeech.googleapis.com/v1/text:synthesize?key=$GOOGLE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "input": {
          "text": "Lets solve the equation: x plus 10 equals 5. To isolate x, we subtract 10 from both sides. On the right, 5 minus 10 equals negative 5. On the left, positive 10 and negative 10 cancel out, leaving x.  Therefore, x equals negative 5."
        },
        "voice": {
          "languageCode": "en-US",
          "name": "en-US-Neural2-F",
          "ssmlGender": "FEMALE"
        },
        "audioConfig": {
          "audioEncoding": "MP3",
          "speakingRate": 0.95,
          "pitch": 0.0
        }
      }' \
    | python3 -c "import sys, json, base64; data=json.load(sys.stdin); open('$AUDIO_MP3','wb').write(base64.b64decode(data['audioContent']))"

    echo "Step 2: Converting MP3 to WAV..."
    ffmpeg -y -i "$AUDIO_MP3" "$AUDIO_WAV" 2>/dev/null
    rm -f "$AUDIO_MP3"
    echo "Audio cached to narration.wav — will be reused on future runs."
else
    echo "Reusing cached narration.wav (delete it to regenerate)."
fi

echo "Step 3: Merging audio with video..."
VIDEO_DURATION=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO")
ffmpeg -y \
  -i "$VIDEO" \
  -i "$AUDIO_WAV" \
  -filter_complex "[1:a]apad,atrim=duration=$VIDEO_DURATION[a]" \
  -map 0:v \
  -map "[a]" \
  -c:v copy \
  -shortest \
  "$OUTPUT" 2>/dev/null

echo ""
echo "Done! Output saved to: $OUTPUT"
