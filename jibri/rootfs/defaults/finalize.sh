#!/bin/bash
RECORDINGS_DIR=$1

meeting_url=$(cat $RECORDINGS_DIR/metadata.json | jq -r '.meeting_url')
meeting_name=$(basename $meeting_url)
recording_file=$(find $RECORDINGS_DIR -type f -name '*.mp4' | head -n 1)

request="{ \"FilePath\": \"$recording_file\", \"MeetingId\": \"$meeting_name\", \"RecorderKey\": \"$JIBRI_RECORDER_PASSWORD\" }"
echo $request
(
  curl --retry-connrefused --retry 10000 -s -w "\\n FinishRecording webhook result\\nResponse code: %{http_code}\\nSend to: %{url_effective}\\nMeeting ID: $meeting_name\\n\\n" -X POST \
    -H "Content-Type: application/json" \
    -d "$request" \
    http://concerto_server/Session/RecordingFinished
) & disown

echo "Finalize script for $meeting_name finished"