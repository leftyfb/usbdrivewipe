#!/bin/bash

echo "17" > /sys/class/gpio/unexport
echo "17" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio17/direction

echo "0" > /tmp/bootstat.tmp
booted=$(cat /tmp/bootstat.tmp)

while [ "$booted" = "0" ]
 do
  booted=$(cat /tmp/bootstat.tmp)
  echo "0" > /sys/class/gpio/gpio17/value
  sleep .5
  echo "1" > /sys/class/gpio/gpio17/value
  sleep .5
done
  echo "0" > /sys/class/gpio/gpio17/value
