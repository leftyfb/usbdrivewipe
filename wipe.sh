#!/bin/bash

echo "17" > /sys/class/gpio/unexport
echo "18" > /sys/class/gpio/unexport
echo "25" > /sys/class/gpio/unexport
echo "17" > /sys/class/gpio/export
echo "18" > /sys/class/gpio/export
echo "25" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio17/direction
echo "out" > /sys/class/gpio/gpio18/direction
echo "out" > /sys/class/gpio/gpio25/direction


# Turn yellow LED on to indicate it is ready
echo "1" > /sys/class/gpio/gpio25/value

sleep 2

waiting=0
while true; do 
	usbstick=$(ls -l /dev/disk/by-id/usb* 2>/dev/null|head -n1|awk '{print $11}'|awk -F "/" '{print $3}')
	if [ -n "$usbstick" ] && [ $waiting = "0" ]; then
		echo -e "USB DRIVE INSERTED AT /dev/$usbstick"
		wiping=1
		# "Turn yellow off"
        	echo "0" > /sys/class/gpio/gpio25/value
		echo -e "\nWiping USB drive......"
		while [ $wiping = 1 ];do
			# blink RED LED
  			/etc/init.d/blink start
			#echo "Shredding disk..."
			#shred -n1 -v /dev/$usbstick
			dd if=/dev/zero of=/dev/$usbstick bs=1024 count=76202
			echo "labeling disk..."
			parted -s /dev/$usbstick mklabel msdos
			echo "partitioning disk..."
			parted /dev/$usbstick --script -- mkpart primary 0 -1
			echo "formatting disk..."
			mkfs.vfat -n USBDRIVE /dev/$(echo $usbstick)1
#			echo "Mounting /dev/$(echo $usbstick)1..."
#			mount /dev/$(echo $usbstick)1 /mnt/
#			echo "Creating truecrypt volume..."
#			/usr/local/bin/truecrypt -t -c \
#			--keyfiles=tc.key \
#			--password=testpass \
#			--volume-type=normal \
#			--size=94967296 \
#			--filesystem=FAT \
#			--encryption=AES \
#			--hash=SHA-512 \
#			--random-source=/dev/random /mnt/truecrypt.tc
##			sleep 1
#			echo "Umounting usb drive..."
#			umount /mnt/
			/etc/init.d/blink stop
			sleep 2
			#Turn green LED back on
        		echo "1" > /sys/class/gpio/gpio18/value
			echo -e "\nWIPE DONE. Please Remove drive"
			sleep 5
			wiping=0
			waiting=1
		done
	elif [ $waiting = "1" ]; then
		if [ -z "$usbstick" ]; then
			waiting=0
		fi
	else
		# Turn green LED off
        	echo "0" > /sys/class/gpio/gpio18/value
		# Turn yellow LED on
		echo "1" > /sys/class/gpio/gpio25/value
		echo "Please insert USB drive"
		sleep 1
	fi
done
