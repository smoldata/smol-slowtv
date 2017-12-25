#!/bin/sh

sudo ntpdate time.nist.gov
cd /usr/local/smol/smol-slowtv && git pull origin master

video=/home/pi/bergensbanen.mp4
video_length=26053

today=`date -u +%Y-%m-%d`
#echo $today

midnight=`date -u --date="$today" +%s`
#echo $midnight

now=`date -u +%s`
#echo $now

elapsed=`expr $now - $midnight`
#echo $elapsed

start_time=`expr $elapsed % $video_length`
#echo $start_time

start_h=`expr $start_time / 3600`
#echo $start_h

start_i=`expr $start_h \* 3600`
#echo $start_i

start_j=`expr $start_time - $start_i`
#echo $start_j

start_m=`expr $start_j / 60`
#echo $start_m

start_n=`expr $start_m \* 60`
#echo $start_n

start_s=`expr $start_time - $start_i`
#echo $start_s

start_s=`expr $start_s - $start_n`
#echo $start_s

if [ $start_h -lt 10 ]
then
   start_h="0$start_h"
fi

if [ $start_m -lt 10 ]
then
    start_m="0$start_m"
fi

if [ $start_s -lt 10 ]
then
    start_s="0$start_s"
fi

start="$start_h:$start_m:$start_s"

/usr/bin/omxplayer -b --loop --no-osd --vol "-6000" --pos "$start" $video
