#!/bin/sh

# This shell script should be installed as a @reboot cron job:
# @reboot /usr/local/smol/smol-slowtv/play.sh

# Update the current time
sudo ntpdate time.nist.gov

# Note: If you edit this file `git pull origin master` will stop updating.
cd /usr/local/smol/smol-slowtv && git pull origin master

# These get overridden with arguments passed in:
# @reboot /usr/local/smol/smol-slowtv/play.sh [video] [video_length] [volume]
video=/home/pi/video.mp4
video_length=26053
volume=-6000          # sound is disabled by default (set to 0 to include sound)

if [ $1 ]
then
	video=$1
fi

if [ $2 ]
then
	video_length=$2
fi

if [ $3 ]
then
	volume=$3
fi

# Calculate when the video should start, $start_time, in seconds
today=`date -u +%Y-%m-%d`
midnight=`date -u --date="$today" +%s`
now=`date -u +%s`
elapsed=`expr $now - $midnight`
start_time=`expr $elapsed % $video_length`

# Hours
start_h=`expr $start_time / 3600`
start_i=`expr $start_h \* 3600`
start_j=`expr $start_time - $start_i`
if [ $start_h -lt 10 ]
then
	start_h="0$start_h"
fi

# Minutes
start_m=`expr $start_j / 60`
start_n=`expr $start_m \* 60`
if [ $start_m -lt 10 ]
then
	start_m="0$start_m"
fi

# Seconds
start_s=`expr $start_time - $start_i`
start_s=`expr $start_s - $start_n`
if [ $start_s -lt 10 ]
then
	start_s="0$start_s"
fi

# Start time, as a timestamp: HH:MM:SS
start="$start_h:$start_m:$start_s"

# Finally, start playing the video back
/usr/bin/omxplayer -b --loop --no-osd --vol "$volume" --pos "$start" "$video"
