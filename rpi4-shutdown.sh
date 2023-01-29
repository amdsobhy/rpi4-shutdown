#!/bin/bash

set -e

function onError {
   echo "Unexporting GPIO"
   echo 5 > /sys/class/gpio/unexport
   exit 1
}

function onExit {
   exit 0
}

trap onExit EXIT
trap onError ERR

which inotifywait > /dev/null
if [[ "$?" == "1" ]]; then
    sudo apt update && sudo apt install inotify-tools -y
fi

# Set gpio to input and rising edge triggered
if [[ ! -d /sys/class/gpio/gpio5 ]]; then
    echo 5 > /sys/class/gpio/export
fi

echo in > /sys/class/gpio/gpio5/direction
echo rising > /sys/class/gpio/gpio5/edge

# Block wait for a gpio change in value
inotifywait -t 0 -e modify /sys/class/gpio/gpio5/value
if [[ "$?" == "0" ]]; then
    echo "Power Button Pressed! Shutting Down..."
    shutdown 0
else
    echo "inotifywait failed!
fi

