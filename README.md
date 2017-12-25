# smol-slowtv

![Slow TV](https://slowtv.smoldata.org/img/smol-slowtv.jpg)

A basic Raspberry Pi video player, designed to play with Very Long Videos such as [BergensBanen minutt for minutt](https://www.youtube.com/watch?v=z7VYVjR_nwE&list=PL_WssN5hKWUY9exh9UonSJBO9ntpL137Y&index=1). All players synchronize their playback, so that when you're watching you see the same thing as everyone else.

When the Pi boots up, it updates its time using `ntpdate`, pulls down any updates from [this git repo](https://github.com/smoldata/smol-slowtv), then plays back starting from a specific timestamp based on the current UTC time. This allows for a [communal slow TV viewing experience](http://www.newyorker.com/culture/cultural-comment/slow-tv).

## Materials

* Raspberry Pi (tested with [Pi 1 Model B+](https://www.raspberrypi.org/products/raspberry-pi-1-model-b/), and [Pi 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/))
* HDMI-capable screen
* HDMI cable
* Micro USB cable and power supply
* USB keyboard
* 16GB Micro SD card
* 16GB USB thumb drive formatted for Mac OS HFS+
* A working wifi network

This guide assumes you are using a Mac to set things up, if you're using Linux or Windows some of the details will be slightly different.

## Download the video

First, install [`youtube-dl`](https://rg3.github.io/youtube-dl/), then use it to download the video you want to play. Depending on the length of video, this may take a really long time and will require 8.64GB of free disk space. Luckily `youtube-dl` supports resuming partially downloaded videos.

```
youtube-dl "https://www.youtube.com/watch?v=z7VYVjR_nwE"
```

You can leave this running in a separate Terminal tab. You should end up with a file whose name matches the title of the video you downloaded. Rename it to `video.mp4` and then copy it to the USB thumb drive.

## Prepare Raspbian SD Card

* Download [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/)
* Plug in the SD Card
* Open the terminal and type `df`

You should see a list of mounted filesystems, and you need to figure out which one is the SD card. It will probably be last in the list, and will likely be called something like `NO NAME`. The left-most column will say which device number the SD card has. Look for something like `/dev/disk2`.

If you're uncertain, try checking `df` before and after you insert the SD card and check for a new item appearing in the list.

__Important__: if you get the device number wrong, you could easily format the wrong disk. Don't do that, it will ruin your whole day.

Next, type in the following variables. Yours will likely be different. Don't continue if you're not sure if these are the correct values.

```
disknum=2
raspbian=/Users/dphiffer/Downloads/2017-11-29-raspbian-stretch-lite.img
```

Now we can write to the SD card using the variables we just set.

```
diskutil unmountDisk /dev/disk$disknum
sudo dd bs=1m if=$raspbian of=/dev/rdisk$disknum
sudo diskutil eject /dev/disk$disknum
```

## Setup the Pi

Insert the SD card into the Pi, plug in the HDMI cable, the keyboard, and power. You should see a boot sequence, and end up on a console login screen.

Username: `pi`
Password: `raspberry`

Now you should run the Raspberry Pi config utility.

```
sudo raspi-config
```

Depending on what kind of keyboard you have, and what your language and timezone preferences are, you should choose the following items from the menu:

* Change User Password
* Network Options
	- Hostname (give your Pi a name)
	- Wi-Fi
* Localisation Options
	- Change Locale (I choose `en_US-UTF-8 UTF-8`)
	- Change Timezone
	- Change Keyboard Layout (I choose `US English`)
	- Change Wi-fi Country
* Interfacing Options
	- Enable SSH
* Finish and reboot

When the Pi comes back from rebooting, login with the new password you just set and use the following to figure out the IP address of your Pi:

```
ifconfig wlan0 | grep inet
```

In my case I got the following:

```
inet 192.168.1.32  netmask 255.255.255.0  broadcast 192.168.1.255
inet6 2600:1010:b15e:211f:7171:e902:e23b:a30b  prefixlen 64  scopeid 0x0<global>
inet6 fd00::ff98:a29b:12b:a31a  prefixlen 64  scopeid 0x0<global>
inet6 fe80::4466:76a0:10a2:6612  prefixlen 64  scopeid 0x20<link>
```

The first line includes the current IP address, `192.168.1.32`.

## Continue Pi setup via SSH

Use the IP address to SSH in from your Mac, which should make copy/pasting commands easier (note that you will need to substitute your Pi's IP address in here):

```
ssh pi@192.168.1.32
```

Then type the following commands to finish the Pi setup:

```
sudo apt update
sudo apt upgrade -y
sudo apt install -y git hfsplus hfsutils hfsprogs omxplayer ntpdate
```

## Setup smol-slowtv

Clone the [smol-slowtv repo](https://github.com/smoldata/smol-slowtv):

```
sudo mkdir /usr/local/smol
sudo chown pi /usr/local/smol
cd /usr/local/smol
git clone https://github.com/smoldata/smol-slowtv.git
```

Setup the cron job:

```
crontab -e
```

Choose which editor you want to edit your cron jobs with. If you don't have an existing preference, you should probably pick `nano`.

Add the following line to the bottom of the crontab:

```
@reboot /usr/local/smol/smol-slowtv/play.sh
```

__Optional__: If you're using a video that's _not_ the [BergensBanen](https://www.youtube.com/watch?v=z7VYVjR_nwE&list=PL_WssN5hKWUY9exh9UonSJBO9ntpL137Y&index=1), you will want to assign the video path and video length (in seconds) as arguments to the shell script:

```
# arg1: full path to the video file
# arg2: the video length, in seconds
@reboot /usr/local/smol/smol-slowtv/play.sh /home/pi/video.mp4 26053
```

If you omit those arguments the script will assume your video is 26,053 seconds long.

Make sure to end the line with a line break, by hitting the return key. The cron job will not work if the last item doesn't have a line break. Save and exit the editor.

## Setup the video

Take the USB thumb drive with the video you downloaded above and insert it into the Pi.

Mount the disk using the following command:

```
sudo mount /dev/sda2 /mnt
```

It's possible your specific USB thumb drive won't be `/dev/sda2` but that's a good first guess.

Check to make sure the video file is there:

```
cd /mnt
ls
```

You should see `video.mp4`. Copy it to your home directory:

```
cp video.mp4 /home/pi/video.mp4
```

That will take a while.

## Reboot

Once you reboot your Pi and plug its HDMI cable into a TV, your video should start playing automatically, on a loop.
